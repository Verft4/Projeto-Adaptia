import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 1. O GoogleSignIn agora é um Singleton. Não passamos mais os scopes aqui.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Função de Login por Email/Senha (Sem alterações)
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

  // Função de Cadastro por Email/Senha (Sem alterações)
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

  // Função login com Google (Totalmente atualizada para v7.0.0+)
  Future<String?> loginComGoogle() async {
    try {
      // 2. Inicialização é obrigatória na nova versão antes de autenticar
      await _googleSignIn.initialize();

      // 3. Usa-se authenticate() em vez de signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        return 'Login cancelado pelo usuário.';
      }

      // 4. Definir os escopos que você precisa
      final List<String> scopes = ['email', 'profile'];

      // 5. Solicitar a autorização para gerar o accessToken
      final clientAuth = await googleUser.authorizationClient.authorizationForScopes(scopes) 
                      ?? await googleUser.authorizationClient.authorizeScopes(scopes);

      // 6. Resgatar os tokens de forma correta
      final String? idToken = googleUser.authentication.idToken; // Identidade (Síncrono)
      final String accessToken = clientAuth.accessToken;         // Permissões

      // 7. Repassar para o Firebase
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