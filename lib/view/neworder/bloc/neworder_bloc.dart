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
    // Debug: log all socket events received
    _socket.onAny((event, data) {
      log('🔎 [SOCKET] Event: $event, Data: $data');
    });
    log("socket init called");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final vendorId = prefs.getString('vendorId') ?? '';

    _socket = IO.io(
      'https://mm-food-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) async {
      log('✅ Socket.IO connected: ${_socket.id}');
      // Join vendor room after connection
      if (vendorId.isNotEmpty) {
        _socket.emit('joinVendorRoom', vendorId);
        log('🔗 Joined vendor room: $vendorId');
      } else {
        log('⚠ VendorId missing, cannot join room');
      }
    });

    _socket.onConnectError((data) => log('⚠ Connection Error: $data'));
    _socket.onError((data) => log('⚠ Socket Error: $data'));
    _socket.onDisconnect((_) {
      log('❌ Socket.IO disconnected');
    });

    // Listen for 'OrderUpdated' event from backend
    void handleOrderUpdatedEvent(dynamic data, String eventName) async {
      log('📩 Received $eventName event: $data');
      await audioPlayer.play(AssetSource('homepageicons/chimes_effect.mp3'));
      try {
        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map) {
          ordersList = [data];
        } else {
          log('⚠ Unexpected data type for $eventName');
          return;
        }
        final orders = ordersList
            .map((json) => Order.fromJson(json))
            .toList()
            .cast<Order>();

        ordersForHome = orders;
        lastOrderCount = orders.length;
        _ordersController.add(orders);
        // Instantly update UI by dispatching a custom event
        add(OrdersUpdatedFromSocket(orders));
      } catch (e, stack) {
        log('❌ Error processing $eventName: $e\n$stack');
      }
    }

    _socket.on(
      'OrderUpdated',
      (data) => handleOrderUpdatedEvent(data, 'OrderUpdated'),
    );
    // If you want to keep compatibility with old event names, you can add:
    // _socket.on(
    //   'orderUpdated',
    //   (data) => handleOrderUpdatedEvent(data, 'orderUpdated'),
    // );
  }

  Future<void> _onOrdersUpdatedFromSocket(
    OrdersUpdatedFromSocket event,
    Emitter<NeworderState> emit,
  ) async {
    emit(NeworderLoaded(event.orders));
  }

  Future<void> playNotificationSound() async {
    await audioPlayer.play(AssetSource('homepageicons/chimes_effect.mp3'));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _ordersController.close();
    _socket.dispose(); // ✅ clean socket
    audioPlayer.dispose();
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

        // sound only when new orders come
        if (orders.length > lastOrderCount) {
          await playNotificationSound();
        }

        lastOrderCount = orders.length;
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
