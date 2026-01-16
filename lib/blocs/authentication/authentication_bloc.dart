import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../globals.dart';
import '../../repositories/authentication/authentication_repository.dart';
import '../../repositories/connection/connection_repositories.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  ConnectionRepository connectionRepository;
  AuthRepository authRepository;

  AuthenticationBloc({
    required this.connectionRepository,
    required this.authRepository,
  }) : super(AuthenticationInitialState()) {
    on<AuthenticationEvent>((event, emit) async {
      bool isConnected = await connectionRepository.isConnectedToInternet();
      if (isConnected) {
        if (event is SignInWithEmailAndPasswordEvent) {
          // Sign-In with Email and Password
          await _signInWithEmailAndPassword(event, emit);
        } else if (event is SignUpWithEmailAndPasswordEvent) {
          // Sign-Up with Email and Password
          await _signUpWithEmailAndPassword(event, emit);
        } else if (event is SendOtpEvent) {
          await _onSendOtp(event, emit);
        } else if (event is VerifyOtpEvent) {
          await _onVerifyOtp(event, emit);
        } else if (event is SignInWithGoogleEvent) {
          await _signInWithGoogle(event, emit);
        } else if (event is SignOutEvent) {
          await _signOutUser(event, emit);
        } else if (event is ResetPasswordEvent){
          await _resetPassword(event, emit);
        }
      } else {
        _safeEmit(emit, NoInternetConnectionState());
      }
    });

    on<CheckAuthStatusEvent>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(const AuthenticationSuccessState(isAuthenticated: true));
      } else {
        emit(AuthenticationInitialState());
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Safely emit a state only if the handler is still active
  void _safeEmit(Emitter<AuthenticationState> emit, AuthenticationState state) {
    if (emit.isDone) return;
    emit(state);
  }

  // ---------------------------------------------------------------------------
  // Sign-In with Email and Password
  Future<void> _signInWithEmailAndPassword(
    SignInWithEmailAndPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    _safeEmit(emit, const LoadingState(isLoading: true));
    try {
      final credential = await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential != null) {
        emit(AuthenticationSuccessState(isAuthenticated: true));
      } else {
        // FIX: Create a NEW instance instead of casting
        _safeEmit(
          emit,
          ErrorState(CustomException(message: "Failed to sign in.")),
        );
      }
    } catch (e) {
      if (e is CustomException) {
        _safeEmit(emit, ErrorState(e));
      } else {
        // Wrap generic errors into your CustomException format
        _safeEmit(emit, ErrorState(CustomException(message: e.toString())));
      }
    }
  }

  // Sign-Up with Email and Password
  Future<void> _signUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      _safeEmit(emit, const LoadingState(isLoading: true));
      await authRepository.signUpWithEmailAndPassword(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      _safeEmit(emit, const AuthenticationSuccessState(isAuthenticated: true));
      await authRepository.handleAuthentication();
    } on CustomException catch (error) {
      _safeEmit(emit, ErrorState(error));
    }
  }

  // Send OTP
  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    _safeEmit(emit, const LoadingState(isLoading: true));
    try {
      final completer = Completer<AuthenticationState>();
      await authRepository.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          if (!completer.isCompleted) {
            _safeEmit(emit, const SusseccMessageState("OTP sent successfully"));
            _safeEmit(emit, const LoadingState(isLoading: false));
            completer.complete(OtpSentState(verificationId: verificationId));
            
          }
        },

        onFailed: (error) {
          if (!completer.isCompleted) {
            _safeEmit(emit, const LoadingState(isLoading: false));

            completer.complete(
              ErrorState(
                CustomException(
                  message: error.message ?? "Verification failed",
                ),
              ),
            );
          }
        },
      );
      _safeEmit(emit, const LoadingState(isLoading: false));

      // Wait for the result from callbacks and emit while handler is active
      final nextState = await completer.future;
      _safeEmit(emit, nextState);
    } catch (e) {
      _safeEmit(emit, ErrorState(CustomException(message: e.toString())));
      _safeEmit(emit, const LoadingState(isLoading: false));
    }
  }

  // Verify OTP
  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    _safeEmit(emit, const LoadingState(isLoading: true));
    try {
      // await authRepository.signInWithOtp(event.verificationId, event.smsCode);
      await authRepository.signInWithOtpsmaple(event.verificationId, event.smsCode);
      _safeEmit(emit, const LoadingState(isLoading: false));
      _safeEmit(emit, const AuthenticationSuccessState(isAuthenticated: true));
    } catch (e) {
      _safeEmit(emit, const LoadingState(isLoading: false));
      _safeEmit(emit, ErrorState(CustomException(message: "Invalid OTP Code")));
    }
  }

  // Sign-In with Google
  Future<void> _signInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    _safeEmit(emit, const GoogleLoadingState(isLoading: true));
    try {
      final userCredential = await authRepository.signInWithGoogle();
      _safeEmit(emit, const GoogleLoadingState(isLoading: false));
      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          _safeEmit(emit, GoogleSignInSuccessState(user: user));
          await authRepository.handleAuthentication();
        } else {
          _safeEmit(
            emit,
            ErrorState(CustomException(message: "Google Sign-In Failed")),
          );
          _safeEmit(emit, const GoogleLoadingState(isLoading: false));
        }
      }
    } catch (e) {
      _safeEmit(emit, ErrorState(CustomException(message: e.toString())));
      _safeEmit(emit, const GoogleLoadingState(isLoading: false));
    }
  }

  // Sign-Out User
  Future<void> _signOutUser(
    SignOutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      _safeEmit(emit, const LoadingState(isLoading: true));
      _safeEmit(emit, const GoogleLoadingState(isLoading: true));

      await authRepository.signOut();
      _safeEmit(emit, const GoogleLoadingState(isLoading: false));
      _safeEmit(emit, const LoadingState(isLoading: false));

      _safeEmit(emit, AuthenticationInitialState());
    } catch (e) {
      final errorMessage = e is CustomException ? e.message : e.toString();
      _safeEmit(emit, ErrorState(CustomException(message: errorMessage)));
    } finally {
      if (state is! AuthenticationInitialState) {
        _safeEmit(emit, const LoadingState(isLoading: false));
        _safeEmit(emit, const GoogleLoadingState(isLoading: false));
      }
    }
  }

  // Reset Password
  Future<void> _resetPassword(
    ResetPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      _safeEmit(emit, const LoadingState(isLoading: true));
      await authRepository.resetPassword(event.email);
      _safeEmit(emit, const LoadingState(isLoading: false));
      _safeEmit(emit, SusseccMessageState("We have sent a password reset link to ${event.email}. Please check your inbox and follow the instructions to reset your password."));
    } catch (e) {
      final errorMessage = e is CustomException ? e.message : e.toString();
      _safeEmit(emit, ErrorState(CustomException(message: errorMessage)));
      _safeEmit(emit, const LoadingState(isLoading: false));  
    }
  }
}
