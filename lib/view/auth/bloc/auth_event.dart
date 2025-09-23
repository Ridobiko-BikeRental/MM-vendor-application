
sealed class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String mobile;
  final String password;
  SignupRequested(this.fullName, this.email,this.mobile, this.password);
}
