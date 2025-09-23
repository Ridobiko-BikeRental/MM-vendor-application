import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/ordermealmodel.dart';
import 'newmealorder_event.dart';
import 'newmealorder_state.dart';

class MealBoxOrderBloc extends Bloc<NewMealorderEvent, NewMealorderState> {
  List<MealBoxOrder> mealOrdersForHome = [];
  final StreamController<List<MealBoxOrder>> _ordersController =
      StreamController.broadcast();
  Timer? _pollingTimer;
  final AudioPlayer audioPlayer = AudioPlayer();
  int lastOrderCount = 0;
  late IO.Socket _socket;

  Stream<List<MealBoxOrder>> get ordersStream => _ordersController.stream;

  MealBoxOrderBloc() : super(NewMealorderInitial()) {
    on<FetchAllMealOrders>(_onFetchMealOrders);
    on<ConfirmMealOrderEvent>(_onConfirmMealOrder);
    on<CancelMealOrderEvent>(_onCancelMealOrder);
    on<DeliveredMealOrderEvent>(_onDeliveredMealOrder);

    _initSocket();
  }

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    _socket = IO.io(
      'https://mm-food-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      log('✅ Socket.IO connected: ${_socket.id}');
    });

    _socket.onConnectError((data) => log('⚠️ Connection Error: $data'));
    _socket.onError((data) => log('⚠️ Socket Error: $data'));
    _socket.onReconnectAttempt((attempt) {
      log('🔄 Reconnection Attempt: $attempt');
    });

    _socket.on('mealOrderUpdated', (data) async {
      log('📩 Received mealboxOrderUpdated event: $data');
      await audioPlayer.play(AssetSource('homepageicons/chimes_effect.mp3'));
      try {
        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map) {
          ordersList = [data];
        } else {
          log('⚠️ Unexpected data type for mealboxOrderUpdated');
          return;
        }

        final mealOrders = ordersList
            .map((json) => MealBoxOrder.fromJson(json))
            .toList();

        mealOrdersForHome = mealOrders;
        _ordersController.add(mealOrders);

        // if (mealOrders.length > lastOrderCount) {
        log('🔔 New order(s) detected. Playing sound...');
        lastOrderCount = mealOrders.length;
        // Play a notification sound

        // }

        // refresh UI state
        add(FetchAllMealOrders());
      } catch (e, stackTrace) {
        log('❌ Error processing mealboxOrderUpdated: $e\n$stackTrace');
      }
    });

    _socket.onDisconnect((_) {
      log('❌ Socket.IO disconnected');
    });
  }

  Future<void> _onFetchMealOrders(
    FetchAllMealOrders event,
    Emitter<NewMealorderState> emit,
  ) async {
    emit(NewMealorderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        emit(NewMealorderError("Please log in"));
        return;
      }

      final url = Uri.parse(
        'https://mm-food-backend.onrender.com/api/mealbox/order',
      );
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ordersJson = data['orders'] ?? [];
        final String? vendorId = prefs.getString('vendorID');

        final filteredOrdersJson = vendorId == null
            ? ordersJson
            : ordersJson
                  .where(
                    (json) =>
                        json['vendor'] != null &&
                        json['vendor']['_id'] == vendorId,
                  )
                  .toList();

        final mealOrders = filteredOrdersJson
            .map((json) => MealBoxOrder.fromJson(json))
            .toList();

        mealOrdersForHome = mealOrders;
        lastOrderCount = mealOrders.length;

        _ordersController.add(mealOrders);
        // if (mealOrders.length > lastOrderCount) {
        //   log('🔔 New order(s) detected. Playing sound...');
        //   lastOrderCount = mealOrders.length;
        //   // Play a notification sound

        // }
        emit(NewMealorderLoaded(mealOrders));
      } else {
        emit(
          NewMealorderError("Failed to load orders: ${response.statusCode}"),
        );
      }
    } catch (e) {
      emit(NewMealorderError("Error: $e"));
    }
  }

  Future<void> _onConfirmMealOrder(
    ConfirmMealOrderEvent event,
    Emitter<NewMealorderState> emit,
  ) async {
    emit(ConfirmMealOrderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        emit(ConfirmMealOrderError("Please log in"));
        return;
      }

      final url = Uri.parse(
        'https://mm-food-backend.onrender.com/api/mealbox/order/${event.orderId}/confirm',
      );
      final body = jsonEncode({
        "deliveryTime": event.time,
        "deliveryDate": event.date,
      });

      final res = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (res.statusCode == 200) {
        add(FetchAllMealOrders());
        emit(ConfirmMealOrderSuccess());
      } else {
        emit(ConfirmMealOrderError("Failed: ${res.statusCode}"));
      }
    } catch (e) {
      emit(ConfirmMealOrderError("Error: $e"));
    }
  }

  Future<void> _onCancelMealOrder(
    CancelMealOrderEvent event,
    Emitter<NewMealorderState> emit,
  ) async {
    emit(CancelMealOrderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        emit(CancelMealOrderError("Please log in"));
        return;
      }

      Dio dio = Dio();
      final url =
          'https://mm-food-backend.onrender.com/api/mealbox/order/${event.orderId}/cancel';

      final response = await dio.put(
        url,
        data: {'reason': event.cancelReason},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        add(FetchAllMealOrders());
        emit(CancelMealOrderSuccess());
      } else {
        emit(CancelMealOrderError("Failed: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CancelMealOrderError("Error: $e"));
    }
  }

  Future<void> _onDeliveredMealOrder(
    DeliveredMealOrderEvent event,
    Emitter<NewMealorderState> emit,
  ) async {
    emit(DeliveredMealOrderLoading());
    try {
      final url = Uri.parse(
        'https://mm-food-backend.onrender.com/api/mealbox/tracking/${event.orderId}/delivered',
      );
      final now = DateTime.now();

      final body = jsonEncode({
        "deliveryDate": DateFormat('yyyy-MM-dd').format(now),
        "deliveryTime": DateFormat('HH:mm').format(now),
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        add(FetchAllMealOrders());
        emit(DeliveredConfirmMealOrderSuccess());
      } else {
        emit(DeliveredConfirmMealOrderError("Failed: ${response.statusCode}"));
      }
    } catch (e) {
      emit(DeliveredConfirmMealOrderError("Error: $e"));
    }
  }

  @override
  Future<void> close() async {
    _pollingTimer?.cancel();
    await audioPlayer.release();
    await audioPlayer.dispose();
    _ordersController.close();
    _socket.disconnect();
    _socket.destroy();
    return super.close();
  }
}
