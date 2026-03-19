// Validação de email e senha

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail.';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha.';
    if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
    return null;
  }
}