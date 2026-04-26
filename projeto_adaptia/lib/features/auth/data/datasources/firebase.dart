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
    GoogleSignInAccount? googleUser;
    try {
      await _googleSignIn.initialize();

      googleUser = await _googleSignIn.authenticate();

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

      final currentUser = _auth.currentUser;
      final alreadyLinkedToGoogle =
          currentUser?.providerData.any(
            (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID,
          ) ??
          false;
      final isSameEmail =
          currentUser?.email?.toLowerCase() == googleUser.email.toLowerCase();

      if (currentUser != null && !alreadyLinkedToGoogle && isSameEmail) {
        await currentUser.linkWithCredential(credential);
        await garantirUsuarioAtualNoFirestore();
        return null;
      }

      await _auth.signInWithCredential(credential);
      await garantirUsuarioAtualNoFirestore();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        await garantirUsuarioAtualNoFirestore();
        return null;
      }

      return 'Erro no Firebase: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao logar com o Google: $e';
    }
  }

  Future<String?> vincularContaGoogle() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return 'Nenhum usuário autenticado.';
    }

    if (currentUser.email == null || currentUser.email!.trim().isEmpty) {
      return 'Sua conta atual nao possui e-mail valido para vincular ao Google.';
    }

    GoogleSignInAccount? googleUser;
    try {
      await _googleSignIn.initialize();
      googleUser = await _googleSignIn.authenticate();

      if (googleUser.email.toLowerCase() != currentUser.email!.toLowerCase()) {
        await _googleSignIn.signOut();
        return 'Escolha a mesma conta Google cadastrada com o e-mail ${currentUser.email}.';
      }

      final scopes = ['email', 'profile'];
      final clientAuth =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final alreadyLinked = currentUser.providerData.any(
        (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID,
      );

      if (!alreadyLinked) {
        await currentUser.linkWithCredential(credential);
      }

      await garantirUsuarioAtualNoFirestore();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        await garantirUsuarioAtualNoFirestore();
        return null;
      }

      if (e.code == 'credential-already-in-use') {
        return 'Esta conta Google ja esta vinculada a outro usuario.';
      }

      if (e.code == 'requires-recent-login') {
        return 'Por seguranca, entre novamente com sua senha antes de vincular o Google.';
      }

      return 'Erro ao vincular conta Google: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao vincular Google: $e';
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deletarContaAtual() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    final uid = user.uid;

    try {
      await _firestore.collection('usuarios').doc(uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Por segurança, faça login novamente antes de deletar sua conta.',
        );
      }
      throw Exception('Erro ao deletar conta: ${e.message}');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Sem permissao para deletar este perfil no Firestore. Verifique as regras da colecao usuarios.',
        );
      }
      throw Exception('Erro ao deletar dados do perfil: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao deletar conta: $e');
    }
  }

  Future<void> atualizarPerfilParticipante({
    required String nome,
    required String headline,
    required String bio,
    required String avatar,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    await user.updateDisplayName(nome);

    await _firestore.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'nome': nome,
      'email': user.email ?? '',
      'headline': headline,
      'bio': bio,
      'avatar': avatar,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
        'headline': '',
        'bio': '',
        'avatar': '',
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
      if (dadosAtuais.containsKey('headline'))
        'headline': dadosAtuais['headline'] ?? '',
      if (dadosAtuais.containsKey('bio'))
        'bio': dadosAtuais['bio'] ?? '',
      if (dadosAtuais.containsKey('avatar'))
        'avatar': dadosAtuais['avatar'] ?? '',
    }, SetOptions(merge: true));
  }
}
