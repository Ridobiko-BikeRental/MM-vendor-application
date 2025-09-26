import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/ordermodel.dart';
import 'neworder_event.dart';
import 'neworder_state.dart';

class NeworderBloc extends Bloc<NeworderEvent, NeworderState> {
  List<Order> ordersForHome = [];
  final StreamController<List<Order>> _ordersController =
      StreamController.broadcast();

  Timer? _pollingTimer;
  final AudioPlayer audioPlayer = AudioPlayer();
  int lastOrderCount = 0;
  late IO.Socket _socket;

  Stream<List<Order>> get ordersStream => _ordersController.stream;

  NeworderBloc() : super(NeworderInitial()) {
    on<FetchAllOrders>(_onFetchOrders);
    on<ConfirmOrderEvent>(_onConfirmOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<DeliveredOrderEvent>(_markOrderDelivered);
    on<OrdersUpdatedFromSocket>(_onOrdersUpdatedFromSocket);

    _initSocket();
  }

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final vendorId = prefs.getString('vendorID') ?? '';

    _socket = IO.io(
      'https://mm-food-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      log('Socket connected: ${_socket.id}');
      if (vendorId.isNotEmpty) {
        _socket.emit('joinVendorRoom', vendorId);
      }
    });

    _socket.on('ordersUpdated', (data) async {
      // log('Received ordersUpdated: $data');
      await audioPlayer.play(AssetSource('homepageicons/chimes_effect.mp3'));

      try {
        final List ordersJson = data is List ? data : (data['orders'] ?? []);
        final orders = ordersJson
            .map((json) => Order.fromJson(json))
            .toList()
            .cast<Order>();
        log('Parsed ${orders.length} orders from socket data');
        ordersForHome = orders;
        _ordersController.add(orders);

        add(OrdersUpdatedFromSocket(orders));
      } catch (e, stack) {
        log('Error processing ordersUpdated: $e\n$stack');
      }
    });
  }

  Future<void> _onOrdersUpdatedFromSocket(
    OrdersUpdatedFromSocket event,
    Emitter<NeworderState> emit,
  ) async {
    _ordersController.add(event.orders);
    emit(NeworderLoaded(event.orders));
  }

  @override
  Future<void> close() {
    _ordersController.close();
    _socket.dispose();
    return super.close();
  }

  Future<void> _onFetchOrders(
    FetchAllOrders event,
    Emitter<NeworderState> emit,
  ) async {
    emit(NeworderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null || token.isEmpty) {
        emit(NeworderError("Please log in again (token missing)"));
        return;
      }

      final url = Uri.parse(
        "https://mm-food-backend.onrender.com/api/orders/all-orders",
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ordersJson = data['orders'] ?? [];
        final orders = ordersJson
            .map((json) => Order.fromJson(json))
            .toList()
            .cast<Order>();

        ordersForHome = orders;
        _ordersController.add(orders);

        emit(NeworderLoaded(orders));
      } else if (response.statusCode == 401) {
        emit(NeworderError("Unauthorized (401) – Please log in again"));
      } else {
        emit(NeworderError("Failed to load orders: ${response.statusCode}"));
      }
    } catch (e) {
      emit(NeworderError("Error: $e"));
    }
  }

  Future<void> _onConfirmOrder(
    ConfirmOrderEvent event,
    Emitter<NeworderState> emit,
  ) async {
    emit(ConfirmOrderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        emit(ConfirmOrderError("Please log in"));
        return;
      }

      final url = Uri.parse(
        "https://mm-food-backend.onrender.com/api/orders/confirm/${event.orderId}",
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
        emit(ConfirmOrderSuccess());
        add(FetchAllOrders()); // refresh list after confirm
      } else {
        emit(ConfirmOrderError("Failed to confirm order: ${res.statusCode}"));
      }
    } catch (e) {
      emit(ConfirmOrderError("Error: $e"));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<NeworderState> emit,
  ) async {
    emit(CancelOrderLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        emit(CancelOrderError("Please log in"));
        return;
      }

      final url = Uri.parse(
        "https://mm-food-backend.onrender.com/api/orders/cancel/${event.orderId}",
      );

      final res = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': event.cancelReason}),
      );

      if (res.statusCode == 200) {
        emit(CancelOrderSuccess());
        add(FetchAllOrders()); // refresh list after cancel
      } else {
        emit(CancelOrderError("Failed to cancel order: ${res.statusCode}"));
      }
    } catch (e) {
      emit(CancelOrderError("Error: $e"));
    }
  }

  Future<void> _markOrderDelivered(
    DeliveredOrderEvent event,
    Emitter<NeworderState> emit,
  ) async {
    emit(DeliveredOrderLoading());
    final url = Uri.parse(
      "https://mm-food-backend.onrender.com/api/orders/tracking/${event.orderId}/delivered",
    );

    final now = DateTime.now();

    try {
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
        emit(DeliveredOrderSuccess());
        add(FetchAllOrders()); // refresh list after delivered
      } else {
        emit(
          DeliveredOrderError(
            "Failed to mark order delivered: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(DeliveredOrderError("Error: $e"));
    }
  }
}
