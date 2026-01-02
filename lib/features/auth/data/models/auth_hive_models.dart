import 'package:frendly/core/constants/hive_table_constant.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_models.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModels extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String phoneNumber;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String dateOfBirth;

  @HiveField(7)
  final String gender;

  @HiveField(8)
  final String? profilePicture;

  @HiveField(9)
  final String? bio;

  AuthHiveModels({
    String? authId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.password,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    this.bio,
  }) : authId = authId ?? Uuid().v4();

  // From Entity to Hive Model
  factory AuthHiveModels.fromEntity(AuthEntity entity) {
    return AuthHiveModels(
      authId: entity.authId,
      username: entity.username,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      profilePicture: entity.profilePicture,
      bio: entity.bio,
    );
  }

  // To Entity from Hive Model
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      username: username,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profilePicture: profilePicture,
      bio: bio,
    );
  }

  // TO Entity List from Hive Model List
  static List<AuthEntity> toEntityList(List<AuthHiveModels> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
