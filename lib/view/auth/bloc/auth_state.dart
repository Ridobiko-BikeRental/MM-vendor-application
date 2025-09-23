sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final String message;
  final dynamic data; // can store token or user details
  AuthSuccess(this.message, {this.data});
}

final class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
