// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:frendly/features/profile/data/profile_remote_datasource.dart';
// import 'package:frendly/features/profile/data/profile_repository_impl.dart';
// import 'package:frendly/features/profile/domain/profile_repository.dart';

// /// 🔹 Dio (reuse if already exists)
// final dioProvider = Provider<Dio>((ref) {
//   return Dio(BaseOptions(baseUrl: "http://10.0.2.2:5000"));
// });

// /// 🔹 Profile Repository Provider ✅ THIS IS THE KEY
// final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
//   final dio = ref.read(dioProvider);
//   final remote = ProfileRemoteDataSource(dio);
//   return ProfileRepositoryImpl(remote);
// });
