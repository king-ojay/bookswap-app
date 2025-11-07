import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Check authentication status
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.getCurrentUserData();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });

    // Sign up
    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUp(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
        );
        if (user != null) {
          emit(AuthAuthenticated(user));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Sign in
    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signIn(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('User not found'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Sign out
    on<AuthSignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}
