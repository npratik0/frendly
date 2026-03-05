// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostHiveModelAdapter extends TypeAdapter<PostHiveModel> {
  @override
  final int typeId = 10;

  @override
  PostHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      username: fields[2] as String,
      fullName: fields[3] as String,
      profilePicture: fields[4] as String?,
      caption: fields[5] as String,
      imageUrl: fields[6] as String,
      likes: (fields[7] as List).cast<String>(),
      comments: (fields[8] as List).cast<CommentHiveModel>(),
      createdAt: fields[9] as String,
      updatedAt: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PostHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.profilePicture)
      ..writeByte(5)
      ..write(obj.caption)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.likes)
      ..writeByte(8)
      ..write(obj.comments)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentHiveModelAdapter extends TypeAdapter<CommentHiveModel> {
  @override
  final int typeId = 11;

  @override
  CommentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommentHiveModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      username: fields[2] as String,
      fullName: fields[3] as String,
      profilePicture: fields[4] as String?,
      text: fields[5] as String,
      createdAt: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CommentHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.profilePicture)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
