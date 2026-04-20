import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> getUsuarioAtual();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;

  AuthRemoteDatasourceImpl({required AuthService authService})
    : _authService = authService;

  /// Lê o documento do usuário atual no Firestore e retorna um UserModel.
  /// O AuthService já garantiu que o doc existe antes desta chamada.
  @override
  Future<UserModel> getUsuarioAtual() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Nenhum usuário autenticado.');

    await _authService.garantirUsuarioAtualNoFirestore();

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('Nao foi possivel sincronizar o usuario no Firestore.');
    }

    return UserModel.fromJson(doc.data()!);
  }
}
