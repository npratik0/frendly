import 'dart:io';

import 'package:frendly/features/profile/data/profile_remote_datasource.dart';
import 'package:frendly/features/profile/domain/profile_repository.dart';
import 'package:frendly/features/profile/domain/user_entity.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<UserEntity> fetchProfile() => remote.getProfile();

  @override
  Future<UserEntity> uploadProfileImage(File image) =>
      remote.uploadImage(image);
}
