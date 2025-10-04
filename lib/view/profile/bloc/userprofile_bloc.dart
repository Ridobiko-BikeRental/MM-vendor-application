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
      // await prefs.setBool('loggedIn', false);

      final response = await http.get(
        Uri.parse('https://munchmartfoods.com/vendor/profile.php'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log("Response body: ${response.body}");
        final vendorMap = data['vendor'];
        if (vendorMap == null) {
          emit(UserProfileError("Vendor data not found"));
          return;
        }

        final userModel = UserModel.fromJson(vendorMap);

        await prefs.setString('vendorID', userModel.vendId);

        log("Profile Data: $data");
        log("profile${userModel.vendId}");

        emit(UserProfileLoaded(userModel));
      } else {
        emit(
          UserProfileError(
            "Could not load profile, Status: ${response.statusCode}",
          ),
        );
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
      var uri = Uri.parse('https://munchmartfoods.com/vendor/profile.php');
      var request = http.MultipartRequest('POST', uri);

      // Add auth token to headers if present
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Remove this, MultipartRequest adds correct content-type and boundary
      // request.headers['Content-Type'] = 'application/json';

      // Convert all values from dynamic to String and add to fields
      final Map<String, String> fields = event.user.toJson().map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      request.fields.addAll(fields);

      // Add image file if exists
      if (event.imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image ',
            event.imageFile!.path,
          ),
        );
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      log("Update Response: ${response.statusCode}, Body: $respStr");

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        emit(UserProfileUpdated(UserModel.fromJson(data['vendor'])));
      } else {
        emit(
          UserProfileError(
            "Could not update profile, Status: ${response.statusCode}",
          ),
        );
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
        Uri.parse('https://munchmartfoods.com/vendor/logout.php'),
        headers: {
          // "Content-Type": "application/json",
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
