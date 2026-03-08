// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/constants/hive_table_constant.dart';
// import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';

// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });

// class HiveService {
//   Future<void> init() async {
//     // Initialization logic here
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstant.dbName}';
//     Hive.init(path);
//     _registerAdapters();
//     await _openBoxes();
//   }

//   void _registerAdapters() {
//     // Register all type adapters here
//     if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
//       Hive.registerAdapter(AuthHiveModelsAdapter());
//     }
//   }

//   Future<void> _openBoxes() async {
//     await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);
//   }

//   // Close all boxes
//   Future<void> close() async {
//     await Hive.close();
//   }

//   // ====================Auth CRUD Operations=====================
//   Box<AuthHiveModels> get _authBox =>
//       Hive.box<AuthHiveModels>(HiveTableConstant.authTable);

//   Future<AuthHiveModels> registerUser(AuthHiveModels model) async {
//     await _authBox.put(model.authId, model);
//     return model;
//   }

//   // login
//   AuthHiveModels? loginUser(String email, String password) {
//     // try {
//     //   return _authBox.values.firstWhere(
//     //     (user) => user.email == email && user.password == password,
//     //   );
//     // } catch (e) {
//     //   return null;
//     // }
//     final users = _authBox.values.where(
//       (user) => user.email == email && user.password == password,
//     );
//     if (users.isNotEmpty) {
//       return users.first;
//     }
//     return null;
//   }

//   // logout
//   Future<void> logoutUser() async {}

//   // get current user
//   AuthHiveModels? getCurrentUser(String authId) {
//     return _authBox.get(authId);
//   }

//   bool isEmailExist(String email) {
//     final users = _authBox.values.where((user) => user.email == email);
//     return users.isNotEmpty;
//   }
// }

// lib/core/services/hive_service.dart
// UPDATED VERSION - Added post and search adapters

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/constants/hive_constants.dart';
import 'package:frendly/core/constants/hive_table_constant.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/features/post/data/models/post_hive_model.dart';
import 'package:frendly/features/search/data/models/recent_search_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    // Initialization logic here
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    // Register auth adapter (existing)
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelsAdapter());
    }

    // Register post adapters (NEW)
    if (!Hive.isAdapterRegistered(HiveConstants.postHiveModelTypeId)) {
      Hive.registerAdapter(PostHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.commentHiveModelTypeId)) {
      Hive.registerAdapter(CommentHiveModelAdapter());
    }

    // Register search adapter (NEW)
    if (!Hive.isAdapterRegistered(HiveConstants.recentSearchHiveModelTypeId)) {
      Hive.registerAdapter(RecentSearchHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    // Open existing auth box
    await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);

    // Open new boxes for post feature
    await Hive.openBox(HiveConstants.authBox);
    await Hive.openBox(HiveConstants.bookmarkedPostsBox);
    await Hive.openBox(HiveConstants.offlineActionsBox);

    // Open search box
    await Hive.openBox<RecentSearchHiveModel>(HiveConstants.recentSearchesBox);
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ====================Auth CRUD Operations=====================
  Box<AuthHiveModels> get _authBox =>
      Hive.box<AuthHiveModels>(HiveTableConstant.authTable);

  Future<AuthHiveModels> registerUser(AuthHiveModels model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // login
  AuthHiveModels? loginUser(String email, String password) {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // logout
  Future<void> logoutUser() async {}

  // get current user
  AuthHiveModels? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  bool isEmailExist(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
