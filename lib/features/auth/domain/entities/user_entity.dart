import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String mobile;
  final String email;
  final String? avatarPath;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    this.avatarPath,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        mobile,
        email,
        avatarPath,
        isActive,
        createdAt,
        updatedAt,
      ];
}
