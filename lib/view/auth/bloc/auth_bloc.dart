import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/auth/bloc/auth_event.dart';
import 'package:yumquick/view/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final url = Uri.parse(
      'https://mm-food-backend.onrender.com/api/vendors/login',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': event.email, 'password': event.password}),
      );
      log("${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final token = json['token'] ?? json['data']?['token'];

        log("$token");

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setBool('loggedIn', true);
        }

        log("1");
        emit(AuthSuccess(json['message'] ?? 'Login successful', data: json));
      } else {
        log("2");
        final json = jsonDecode(response.body);
        emit(AuthFailure(json['error'] ?? 'Login failed'));
      }
    } catch (e) {
      log("3");
      emit(AuthFailure('Login error: ${e.toString()}'));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    log("message");
    emit(AuthLoading());
    final url = Uri.parse(
      'https://mm-food-backend.onrender.com/api/vendors/signup',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': event.fullName,
          'email': event.email,
          'mobile': event.mobile,
          'password': event.password,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        emit(AuthSuccess(json['message'] ?? 'Signup successful'));
      } else {
        final json = jsonDecode(response.body);
        emit(AuthFailure(json['error'] ?? 'Signup failed'));
      }
    } catch (e) {
      emit(AuthFailure('Signup error: ${e.toString()}'));
    }
  }
}
