part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class SignInWithEmailAndPasswordEvent extends AuthenticationEvent {
  final String email;
  final String password;

  const SignInWithEmailAndPasswordEvent({
    required this.email,
    required this.password,
  });
}

class SignInWithGoogleEvent extends AuthenticationEvent {}

class SignUpWithEmailAndPasswordEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;

  const SignUpWithEmailAndPasswordEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SendOtpEvent extends AuthenticationEvent {
  final String phoneNumber;
  const SendOtpEvent({required this.phoneNumber});
}

class SignOutEvent extends AuthenticationEvent {}

class CheckAuthStatusEvent extends AuthenticationEvent {}

class VerifyOtpEvent extends AuthenticationEvent {
  final String verificationId;
  final String smsCode;
  const VerifyOtpEvent({required this.verificationId, required this.smsCode});
}
