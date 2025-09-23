import 'dart:io';
import '../model/vendormodel.dart';

abstract class UserprofileEvent {}

class LoadUserProfile extends UserprofileEvent {}

class UpdateUserProfile extends UserprofileEvent {
  final UserModel user;
  final File? imageFile;
  UpdateUserProfile(this.user, {this.imageFile});
}

class LogoutUser extends UserprofileEvent {}
