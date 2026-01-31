import 'package:equatable/equatable.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  registered,
  loading,
  loaded,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final AuthEntity? authEntity;
  final String? uploadedPhotoUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.authEntity,
    this.uploadedPhotoUrl,
  });

  // copyWith method
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AuthEntity? authEntity,
    bool resetUploadedPhotoUrl = false,
    String? uploadedPhotoUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authEntity: authEntity ?? this.authEntity,
      uploadedPhotoUrl: resetUploadedPhotoUrl
          ? null
          : (uploadedPhotoUrl ?? this.uploadedPhotoUrl),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, authEntity];
}
