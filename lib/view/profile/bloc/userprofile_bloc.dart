import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/vendormodel.dart';
import 'userprofile_event.dart';
import 'userprofile_state.dart';

class UserprofileBloc extends Bloc<UserprofileEvent, UserprofileState> {
  // UserModel? userDetails;
  UserprofileBloc() : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserprofileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      log("Token: $token");
      final response = await http.get(
        Uri.parse('https://mm-food-backend.onrender.com/api/vendors/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final id = UserModel.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vendorID', id.vendId);

        log("profile${id.vendId}");

        emit(UserProfileLoaded(UserModel.fromJson(data)));
      } else {
        emit(UserProfileError("Could not load profile"));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserprofileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      var uri = Uri.parse(
        'https://mm-food-backend.onrender.com/api/vendors/profile',
      );
      var request = http.MultipartRequest('PUT', uri);

      // Add auth token to headers if present
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';

      // Convert all values from dynamic to String
      final Map<String, String> fields = event.user.toJson().map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      request.fields.addAll(fields);

      if (event.imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', event.imageFile!.path),
        );
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        emit(UserProfileUpdated(UserModel.fromJson(data['vendor'])));
      } else {
        emit(UserProfileError("Could not update profile"));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<UserprofileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await http.post(
        Uri.parse('https://mm-food-backend.onrender.com/api/vendors/logout'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        //  await prefs.remove('authToken');
        await prefs.setBool('loggedIn', false);

        emit(UserLoggedOut());
      } else {
        emit(UserProfileError("Logout failed"));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
