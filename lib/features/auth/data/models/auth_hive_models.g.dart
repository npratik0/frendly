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
      username: fields[0] as String,
      email: fields[1] as String,
      fullName: fields[2] as String,
      phoneNumber: fields[3] as String,
      password: fields[4] as String?,
      dateOfBirth: fields[5] as String,
      gender: fields[6] as String,
      profilePicture: fields[7] as String?,
      bio: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModels obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.profilePicture)
      ..writeByte(8)
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
