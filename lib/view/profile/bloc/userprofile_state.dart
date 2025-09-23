import '../model/vendormodel.dart';

abstract class UserprofileState {}

class UserProfileInitial extends UserprofileState {}

class UserProfileLoading extends UserprofileState {}

class UserProfileLoaded extends UserprofileState {
  final UserModel user;
  UserProfileLoaded(this.user);
}

class UserProfileUpdated extends UserprofileState {
  final UserModel user;
  UserProfileUpdated(this.user);
}

class UserProfileError extends UserprofileState {
  final String message;
  UserProfileError(this.message);
}

class UserLoggedOut extends UserprofileState {}
