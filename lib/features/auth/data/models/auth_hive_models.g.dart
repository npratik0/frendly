// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelsAdapter extends TypeAdapter<AuthHiveModels> {
  @override
  final int typeId = 0;

  @override
  AuthHiveModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModels(
      authId: fields[0] as String?,
      username: fields[1] as String,
      email: fields[2] as String,
      fullName: fields[3] as String,
      phoneNumber: fields[4] as String,
      password: fields[5] as String?,
      dateOfBirth: fields[6] as String,
      gender: fields[7] as String,
      profilePicture: fields[8] as String?,
      bio: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModels obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.dateOfBirth)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.profilePicture)
      ..writeByte(9)
      ..write(obj.bio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
