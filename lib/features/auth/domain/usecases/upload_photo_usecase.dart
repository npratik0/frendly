import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/core/usecases/app_usecase.dart';
import 'package:frendly/features/auth/data/repositories/auth_repository.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(itemRepository: authRepository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final IAuthRepository _itemRepository;

  UploadPhotoUsecase({required IAuthRepository itemRepository})
    : _itemRepository = itemRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _itemRepository.uploadPhoto(photo);
  }
}
