import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        return 'Senha incorreta.';
      }
      return 'Erro ao logar: ${e.message}';
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  
  Future<String?> registrar({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        return 'Já existe uma conta com este e-mail.';
      }
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

    
      final clientAuth = await googleUser.authorizationClient.authorizationForScopes(scopes) 
                      ?? await googleUser.authorizationClient.authorizeScopes(scopes);

      
      final String? idToken = googleUser.authentication.idToken; // Identidade (Síncrono)
      final String accessToken = clientAuth.accessToken;         // Permissões

    
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);

      return null; 

    } on FirebaseAuthException catch (e) {
      return 'Erro no Firebase: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao logar com o Google: $e';
    }
  }
}