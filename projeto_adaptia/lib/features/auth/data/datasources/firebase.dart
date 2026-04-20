import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await garantirUsuarioAtualNoFirestore();
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        return 'E-mail ou senha incorretos. (Se você usou o Google para criar a conta, faça login pelo Google).';
      } else if (e.code == 'user-not-found') {
        return 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        return 'Senha incorreta.';
      }

      return 'Erro ao logar: ${e.message}';
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<String?> registrar({
    required String email,
    required String password,
    required String nome, // 👈
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(nome);
      await _criarUsuarioNoFirestore(
        user: cred.user!,
        nomeOverride: nome,
      ); // 👈

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'A senha fornecida é muito fraca.';
      if (e.code == 'email-already-in-use')
        return 'Já existe uma conta com este e-mail.';
      return 'Erro ao cadastrar: ${e.message}';
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<String?> loginComGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final List<String> scopes = ['email', 'profile'];

      final clientAuth =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final String? idToken =
          googleUser.authentication.idToken; // Identidade (Síncrono)
      final String accessToken = clientAuth.accessToken; // Permissões

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);
      await garantirUsuarioAtualNoFirestore();

      return null;
    } on FirebaseAuthException catch (e) {
      return 'Erro no Firebase: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao logar com o Google: $e';
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> garantirUsuarioAtualNoFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    await _criarUsuarioNoFirestore(user: user);
  }

  Future<void> _criarUsuarioNoFirestore({
    required User user,
    String? nomeOverride,
  }) async {
    final docRef = _firestore.collection('usuarios').doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'uid': user.uid,
        'nome': nomeOverride ?? user.displayName ?? '',
        'email': user.email ?? '',
        'cargo': '',
        'criadoEm': FieldValue.serverTimestamp(),
      });
      return;
    }

    final dadosAtuais = docSnap.data() ?? <String, dynamic>{};
    final nomeAtualizado =
        (dadosAtuais['nome'] as String?)?.trim().isNotEmpty == true
        ? dadosAtuais['nome'] as String
        : (nomeOverride ?? user.displayName ?? '');

    await docRef.set({
      'uid': user.uid,
      'nome': nomeAtualizado,
      'email': user.email ?? '',
      if (dadosAtuais.containsKey('cargo')) 'cargo': dadosAtuais['cargo'] ?? '',
    }, SetOptions(merge: true));
  }
}
