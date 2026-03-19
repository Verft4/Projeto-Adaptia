// Modelo com fromJson/toJson

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}

/*
O UserModel estende o UserEntity. A entidade é pura (domain), o model sabe
lidar com JSON (data). Quando o Firebase chegar, você só mexe aqui.
*/