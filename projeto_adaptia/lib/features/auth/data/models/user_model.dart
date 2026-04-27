// Modelo com fromJson/toJson

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.nome, // 👈
    super.headline,
    super.bio,
    super.avatar,
    super.googleLinked,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['uid'] as String, // uid = chave no Firestore
    email: json['email'] as String,
    nome: json['nome'] as String? ?? '',
    headline: json['headline'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
    googleLinked: json['googleLinked'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'uid': id,
    'email': email,
    'nome': nome,
    'headline': headline,
    'bio': bio,
    'avatar': avatar,
    'googleLinked': googleLinked,
  };
}

/*
O UserModel estende o UserEntity. A entidade é pura (domain), o model sabe
lidar com JSON (data). Quando o Firebase chegar, você só mexe aqui.
*/
