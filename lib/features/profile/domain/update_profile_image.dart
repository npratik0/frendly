import 'dart:io';

import 'package:frendly/features/profile/domain/profile_repository.dart';

class UpdateProfileImage {
  final ProfileRepository repository;

  UpdateProfileImage(this.repository);

  Future call(File image) {
    return repository.uploadProfileImage(image);
  }
}
