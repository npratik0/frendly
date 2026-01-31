// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/features/profile/domain/profile_repository.dart';
// import 'profile_state.dart';
// import '../../../core/providers/providers.dart';

// final profileViewModelProvider =
//     NotifierProvider<ProfileViewModel, ProfileState>(
//   () => ProfileViewModel(),
// );

// class ProfileViewModel extends Notifier<ProfileState> {
//   late final ProfileRepository _repository;

//   ProviderListenable<ProfileRepository> get profileRepositoryProvider => null;

//   @override
//   ProfileState build() {
//     _repository = ref.read(profileRepositoryProvider);
//     fetchProfile();
//     return const ProfileState();
//   }

//   Future<void> fetchProfile() async {
//     state = state.copyWith(status: ProfileStatus.loading);
//     try {
//       final user = await _repository.fetchProfile();
//       state = state.copyWith(
//         status: ProfileStatus.success,
//         user: user,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: ProfileStatus.error,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> uploadProfileImage(File image) async {
//     try {
//       final updatedUser = await _repository.uploadProfileImage(image);
//       state = state.copyWith(user: updatedUser);
//     } catch (e) {
//       state = state.copyWith(
//         status: ProfileStatus.error,
//         error: e.toString(),
//       );
//     }
//   }
// }

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/profile/domain/profile_repository.dart';
import 'profile_state.dart';
import '../../../core/providers/providers.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(() => ProfileViewModel());

class ProfileViewModel extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.read(profileRepositoryProvider);
    fetchProfile();
    return const ProfileState();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final user = await _repository.fetchProfile();
      state = state.copyWith(status: ProfileStatus.success, user: user);
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> uploadProfileImage(File image) async {
    try {
      final updatedUser = await _repository.uploadProfileImage(image);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }
}
