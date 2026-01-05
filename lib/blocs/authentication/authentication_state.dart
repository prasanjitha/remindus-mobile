part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitialState extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class AuthenticationSuccessState extends AuthenticationState {
  final bool isAuthenticated;
  const AuthenticationSuccessState({required this.isAuthenticated});
  @override
  List<Object> get props => [isAuthenticated];
}

class LoadingState extends AuthenticationState {
  final bool isLoading;

  const LoadingState({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class GoogleLoadingState extends AuthenticationState {
  final bool isLoading;

  const GoogleLoadingState({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class ErrorState extends AuthenticationState {
  final CustomException exception;

  const ErrorState(this.exception);

  @override
  List<Object> get props => [exception];
}

class OtpSentState extends AuthenticationState {
  final String verificationId;
  const OtpSentState({required this.verificationId});

  @override
  List<Object> get props => [verificationId];
}

class GoogleSignInSuccessState extends AuthenticationState {
  final User user;
  const GoogleSignInSuccessState({required this.user});

  @override
  List<Object> get props => [user];
}

class NoInternetConnectionState extends AuthenticationState {}
