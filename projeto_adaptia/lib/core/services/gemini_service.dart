import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String? _apiKey;
  GenerativeModel? _model;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] {
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: _apiKey!);
    }
  }

  Future<String> sendMessage(String text, {Uint8List? fileBytes, String? fileName}) async {
    // Se a chave não existir ou estiver vazia, retorna um mock
    if (_model == null) {
      await Future.delayed(const Duration(seconds: 2));
      if (fileBytes != null) {
        return "Recebi sua mensagem: '$text' e o arquivo PDF anexo '${fileName}'. "
               "Este é um texto de resposta gerado pelo Gemini simulado (mock). "
               "Para usar a API real, adicione GEMINI_API_KEY no seu arquivo .env.";
      }
      return "Resposta mockada do Gemini para: '$text'.\nAdicione a GEMINI_API_KEY no arquivo .env para ter respostas reais.";
    }

    try {
      if (fileBytes != null) {
        final content = [
          Content.multi([
            TextPart(text),
            DataPart('application/pdf', fileBytes),
          ])
        ];
        final response = await _model!.generateContent(content);
        return response.text ?? 'Nenhuma resposta retornada do modelo.';
      } else {
        // Apenas texto
        final content = [Content.text(text)];
        final response = await _model!.generateContent(content);
        return response.text ?? 'Nenhuma resposta retornada do modelo.';
      }
    } catch (e) {
      return "Erro ao processar a requisição com o Gemini: $e";
    }
  }
}
