import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Check if the user is already signed in
class AuthCheckRequested extends AuthEvent {}

// Sign Up event
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

// Sign In event
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Sign Out event
class AuthSignOutRequested extends AuthEvent {}
