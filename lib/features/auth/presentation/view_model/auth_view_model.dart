import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/auth/domain/usecases/login_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/register_usecase.dart';
import 'package:frendly/features/auth/presentation/state/auth_state.dart';

// provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(RegisterUsecaseProvider);
    _loginUsecase = ref.read(LoginUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String dateOfBirth,
    required String gender,
    String? profilePicture,
    String? bio,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecaseParam(
      username: username,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profilePicture: profilePicture,
      bio: bio,
    );
    final result = await _registerUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  void resetState() {
    state = const AuthState();
  }

  // Login method
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
