// Modelo com fromJson/toJson

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.nome, // 👈
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['uid'] as String, // uid = chave no Firestore
    email: json['email'] as String,
    nome: json['nome'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'uid': id, 'email': email, 'nome': nome};
}

/*
O UserModel estende o UserEntity. A entidade é pura (domain), o model sabe
lidar com JSON (data). Quando o Firebase chegar, você só mexe aqui.
*/
