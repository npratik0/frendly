import 'package:frendly/features/profile/domain/user_entity.dart';

import 'dart:io';

abstract class ProfileRepository {
  Future<UserEntity> fetchProfile();
  Future<UserEntity> uploadProfileImage(File image);
}
