import '../../../../core/database/db_tables.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.mobile,
    required super.email,
    super.avatarPath,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[UserColumns.id] as String,
      fullName: map[UserColumns.fullName] as String,
      mobile: map[UserColumns.mobile] as String,
      email: map[UserColumns.email] as String,
      avatarPath: map[UserColumns.avatarPath] as String?,
      isActive: (map[UserColumns.isActive] as int? ?? 1) == 1,
      createdAt: map[UserColumns.createdAt] as int,
      updatedAt: map[UserColumns.updatedAt] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserColumns.id: id,
      UserColumns.fullName: fullName,
      UserColumns.mobile: mobile,
      UserColumns.email: email,
      UserColumns.avatarPath: avatarPath,
      UserColumns.isActive: isActive ? 1 : 0,
      UserColumns.createdAt: createdAt,
      UserColumns.updatedAt: updatedAt,
    };
  }
}
