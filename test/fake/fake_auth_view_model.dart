// // import 'dart:io';

// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import 'package:frendly/features/auth/presentation/state/auth_state.dart';
// // import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
// // import 'package:state_notifier/state_notifier.dart';

// // class FakeAuthViewModel extends StateNotifier<AuthState>
// //     implements AuthViewModel {
// //   FakeAuthViewModel() : super(const AuthState());

// //   @override
// //   Future<void> login({required String email, required String password}) async {
// //     // do nothing (important!)
// //   }

// //   @override
// //   AuthState build() {
// //     // TODO: implement build
// //     throw UnimplementedError();
// //   }

// //   @override
// //   RemoveListener listenSelf(
// //     void Function(AuthState? previous, AuthState next) listener, {
// //     void Function(Object error, StackTrace stackTrace)? onError,
// //   }) {
// //     // TODO: implement listenSelf
// //     throw UnimplementedError();
// //   }

// //   @override
// //   // TODO: implement ref
// //   Ref get ref => throw UnimplementedError();

// //   @override
// //   Future<void> register({
// //     required String username,
// //     required String email,
// //     required String fullName,
// //     required String phoneNumber,
// //     required String password,
// //     required String confirmPassword,
// //     required String dateOfBirth,
// //     required String gender,
// //     String? profilePicture,
// //     String? bio,
// //   }) {
// //     // TODO: implement register
// //     throw UnimplementedError();
// //   }

// //   @override
// //   void resetState() {
// //     // TODO: implement resetState
// //   }

// //   @override
// //   void runBuild() {
// //     // TODO: implement runBuild
// //   }

// //   @override
// //   // TODO: implement stateOrNull
// //   AuthState? get stateOrNull => throw UnimplementedError();

// //   @override
// //   Future<String?> uploadPhoto(File photo) {
// //     // TODO: implement uploadPhoto
// //     throw UnimplementedError();
// //   }
// // }

// // test/fakes/fake_auth_view_model.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:frendly/features/auth/presentation/state/auth_state.dart';

// class FakeAuthViewModel extends StateNotifier<AuthState> {
//   FakeAuthViewModel() : super(const AuthState());
// }

import 'package:frendly/features/auth/presentation/state/auth_state.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';

class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    // Initial safe state for widget tests
    return const AuthState();
  }

  @override
  Future<void> login({required String email, required String password}) async {
    // Do nothing – prevents navigation/snackbar
  }
}
