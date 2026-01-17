import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/core/usecases/app_usecase.dart';
import 'package:frendly/features/auth/data/repositories/auth_repository.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParam extends Equatable {
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String password;
  final String? confirmPassword;
  final String dateOfBirth;
  final String gender;
  final String? profilePicture;
  final String? bio;

  RegisterUsecaseParam({
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    this.bio,
  });
  @override
  List<Object?> get props => [
    username,
    email,
    fullName,
    phoneNumber,
    password,
    confirmPassword,
    dateOfBirth,
    gender,
    profilePicture,
    bio,
  ];
}

//provider for Register Usecase
final RegisterUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParam> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParam params) {
    final entity = AuthEntity(
      username: params.username,
      email: params.email,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      password: params.password,
      confirmPassword: params.confirmPassword,
      dateOfBirth: params.dateOfBirth,
      gender: params.gender,
      profilePicture: params.profilePicture,
      bio: params.bio,
    );
    return _authRepository.register(entity);
  }
}
