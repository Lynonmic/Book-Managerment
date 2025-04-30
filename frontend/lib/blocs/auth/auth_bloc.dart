import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<AuthSignUpEvent>(_onSignUpRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await authRepository.login(event.email, event.password);
      if (response["success"]) {
        emit(AuthSuccess(
          userData: response["userData"],
          role: response["role"],
          token: response["token"],
        ));
      } else {
        emit(AuthFailure(message: response["message"]));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await authRepository.registerUser(
        event.name,
        event.email,
        event.password,
        event.phone,
        event.address,
        event.avatar,
      );
      if (response["success"]) {
        emit(AuthSuccess(
          userData: {},  // Add user data as needed
          role: 1,        // Adjust based on your implementation
          token: "",      // Handle token from response
        ));
      } else {
        emit(AuthFailure(message: response["message"]));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
