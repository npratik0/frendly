// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/constants/hive_table_constant.dart';
// import 'package:hive/hive.dart';
// import 'package:lost_n_found/core/constants/hive_table_constant.dart';
// import 'package:lost_n_found/features/auth/data/models/auth_hive_model.dart';
// import 'package:lost_n_found/features/batch/data/models/batch_hive_model.dart';
// import 'package:lost_n_found/features/category/data/models/category_hive_model.dart';
// import 'package:path_provider/path_provider.dart';

// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });

// class HiveService {
//   Future<void> init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstant.dbName}';
//     Hive.init(path);

//     _registerAdapters();
//     await _openBoxes();

//     await insertBatchDummyData();
//     await insertCategoryDummyData();
//   }

//   Future<void> insertBatchDummyData() async {
//     final batchBox = Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

//     if (batchBox.isNotEmpty) {
//       return;
//     }

//     final dummyBatches = [
//       BatchHiveModel(batchName: '35A'),
//       BatchHiveModel(batchName: '35B'),
//       BatchHiveModel(batchName: '35C'),
//       BatchHiveModel(batchName: '36A'),
//       BatchHiveModel(batchName: '36B'),
//       BatchHiveModel(batchName: '37A'),
//       BatchHiveModel(batchName: '38B'),
//     ];

//     for (var batch in dummyBatches) {
//       await batchBox.put(batch.batchId, batch);
//     }
//   }

//   Future<void> insertCategoryDummyData() async {
//     final categoryBox = Hive.box<CategoryHiveModel>(
//       HiveTableConstant.categoryTable,
//     );

//     if (categoryBox.isNotEmpty) {
//       return;
//     }

//     final dummyCategories = [
//       CategoryHiveModel(
//         name: 'Electronics',
//         description: 'Phones, laptops, tablets, etc.',
//       ),
//       CategoryHiveModel(name: 'Personal', description: 'Personal belongings'),
//       CategoryHiveModel(
//         name: 'Accessories',
//         description: 'Watches, jewelry, etc.',
//       ),
//       CategoryHiveModel(
//         name: 'Documents',
//         description: 'IDs, certificates, papers',
//       ),
//       CategoryHiveModel(
//         name: 'Keys',
//         description: 'House keys, car keys, etc.',
//       ),
//       CategoryHiveModel(
//         name: 'Bags',
//         description: 'Backpacks, handbags, wallets',
//       ),
//       CategoryHiveModel(name: 'Other', description: 'Miscellaneous items'),
//     ];

//     for (var category in dummyCategories) {
//       await categoryBox.put(category.categoryId, category);
//     }
//   }

//   // Register all type adapters
//   void _registerAdapters() {
//     if (!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
//       Hive.registerAdapter(BatchHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTypeId)) {
//       Hive.registerAdapter(CategoryHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.studentTypeId)) {
//       Hive.registerAdapter(AuthHiveModelAdapter());
//     }
//   }

//   // Open all boxes
//   Future<void> _openBoxes() async {
//     await Hive.openBox<BatchHiveModel>(HiveTableConstant.batchTable);
//     await Hive.openBox<AuthHiveModel>(HiveTableConstant.studentTable);
//     await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryTable);
//   }

//   // Delete all batches
//   Future<void> deleteAllBatches() async {
//     await _batchBox.clear();
//   }

//   // Close all boxes
//   Future<void> close() async {
//     await Hive.close();
//   }

//   // ====================Batch CRUD Operations=====================

//   // Get batch box
//   Box<BatchHiveModel> get _batchBox =>
//       Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

//   // Create a new batch
//   Future<BatchHiveModel> createBatch(BatchHiveModel batch) async {
//     await _batchBox.put(batch.batchId, batch);
//     return batch;
//   }

//   // Get all batches
//   List<BatchHiveModel> getAllBatches() {
//     return _batchBox.values.toList();
//   }

//   // Get batch by ID
//   BatchHiveModel? getBatchById(String batchId) {
//     return _batchBox.get(batchId);
//   }

//   // Update a batch
//   Future<void> updateBatch(BatchHiveModel batch) async {
//     await _batchBox.put(batch.batchId, batch);
//   }

//   // Delete a batch
//   Future<void> deletBatch(String batchId) async {
//     await _batchBox.delete(batchId);
//   }

//   // ====================Category CRUD Operations=====================
//   Box<CategoryHiveModel> get _categoryBox =>
//       Hive.box<CategoryHiveModel>(HiveTableConstant.categoryTable);

//   Future<CategoryHiveModel> createCategory(CategoryHiveModel category) async {
//     await _categoryBox.put(category.categoryId, category);
//     return category;
//   }

//   List<CategoryHiveModel> getAllCategories() {
//     return _categoryBox.values.toList();
//   }

//   CategoryHiveModel? getCategoryById(String categoryId) {
//     return _categoryBox.get(categoryId);
//   }

//   Future<bool> updateCategory(CategoryHiveModel category) async {
//     if (_categoryBox.containsKey(category.categoryId)) {
//       await _categoryBox.put(category.categoryId, category);
//       return true;
//     }
//     return false;
//   }

//   Future<void> deleteCategory(String categoryId) async {
//     await _categoryBox.delete(categoryId);
//   }

//   // ====================Auth CRUD Operations=====================
//   Box<AuthHiveModel> get _authBox =>
//       Hive.box<AuthHiveModel>(HiveTableConstant.studentTable);

//   // Register user
//   Future<AuthHiveModel> register(AuthHiveModel user) async {
//     await _authBox.put(user.authId, user);
//     return user;
//   }

//   // Login - find user by email and password
//   AuthHiveModel? login(String email, String password) {
//     try {
//       return _authBox.values.firstWhere(
//         (user) => user.email == email && user.password == password,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // LogOut
//   Future<void> logout() async {}

//   // Get Current User
//   AuthHiveModel? getCurrentUser(String authId) {
//     return _authBox.get(authId);
//   }

//   // Get user by ID
//   AuthHiveModel? getUserById(String authId) {
//     return _authBox.get(authId);
//   }

//   // Get user by email
//   AuthHiveModel? getUserByEmail(String email) {
//     try {
//       return _authBox.values.firstWhere((user) => user.email == email);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Update user
//   Future<bool> updateUser(AuthHiveModel user) async {
//     if (_authBox.containsKey(user.authId)) {
//       await _authBox.put(user.authId, user);
//       return true;
//     }
//     return false;
//   }

//   // Delete user
//   Future<void> deleteUser(String authId) async {
//     await _authBox.delete(authId);
//   }

//   bool doesEmailExist(String email) {
//     final users = _authBox.values.where((user) => user.email == email);
//     return users.isNotEmpty;
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/constants/hive_table_constant.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
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
    // Register all type adapters here
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelsAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);
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
    // try {
    //   return _authBox.values.firstWhere(
    //     (user) => user.email == email && user.password == password,
    //   );
    // } catch (e) {
    //   return null;
    // }
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
