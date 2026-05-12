import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/gemini_service.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final PlatformFile? attachedFile;

  ChatMessage({required this.text, required this.isUser, this.attachedFile});
}

class _AIPageState extends State<AIPage> {
  bool _isChatActive = false;
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  PlatformFile? _selectedFile;
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startNewChat() {
    setState(() {
      _isChatActive = false;
      _messages.clear();
      _textController.clear();
      _selectedFile = null;
    });
  }

  void _startChat() {
    setState(() {
      _isChatActive = true;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedFile == null) return;
    
    final fileToSend = _selectedFile;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text.isEmpty ? 'Arquivo enviado.' : text, 
        isUser: true,
        attachedFile: fileToSend,
      ));
      _textController.clear();
      _selectedFile = null;
      _isLoading = true;
    });

    if (!_isChatActive) {
      _startChat();
    }

    final response = await _geminiService.sendMessage(
      text, 
      fileBytes: fileToSend?.bytes,
      fileName: fileToSend?.name,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
      });
    }
  }

  void _openProfileModal(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selecione um Perfil',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'A IA Adaptará o conteúdo com base no perfil escolhido',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _buildProfileCard(
                  context,
                  "TDAH Fotosensível",
                  ["3º ano", "8 anos", "TEA", "TDAH"],
                  action,
                ),
                _buildProfileCard(
                  context,
                  "Dislexia + TOD",
                  ["3º ano", "8 anos", "Dislexia", "TOD"],
                  action,
                ),
                _buildProfileCard(
                  context,
                  "TEA suporte 2 individual",
                  ["3º ano", "8 anos", "TEA"],
                  action,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context, String title, List<String> tags, String action) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _startChat();
        _sendMessage("$action para o perfil $title");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => _buildTag(tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade700;
    if (text == 'TEA') {
      bgColor = Colors.purple.shade50;
      textColor = Colors.purple;
    } else if (text == 'TDAH') {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange;
    } else if (text == 'Dislexia') {
      bgColor = Colors.teal.shade50;
      textColor = Colors.teal;
    } else if (text == 'TOD') {
      bgColor = Colors.pink.shade50;
      textColor = Colors.pink;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text.contains("ano") || text.contains("anos"))
            Icon(text.contains("ano") ? Icons.people_outline : Icons.calendar_today, size: 12, color: textColor),
          if (text.contains("ano") || text.contains("anos"))
            const SizedBox(width: 4),
          Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Assistente de IA",
          style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.grey),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isChatActive ? _buildChatArea() : _buildInitialArea(),
            ),
            _buildBottomInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewChat();
                },
                icon: const Icon(Icons.edit, color: Colors.lightBlue),
                label: const Text("Nova Conversa", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.lightBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Esta semana", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            _buildDrawerItem("Desenvolvimento psi..."),
            _buildDrawerItem("Criar plano de aula", isSelected: true),
            _buildDrawerItem("Atualizar planilha do..."),
            _buildDrawerItem("Criar ideias de ativida..."),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Mês passado", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            _buildDrawerItem("Desenvolvimento psi..."),
            _buildDrawerItem("Criar plano de aula"),
            _buildDrawerItem("Atualizar planilha do..."),
            _buildDrawerItem("Criar ideias de ativida..."),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, {bool isSelected = false}) {
    return Container(
      color: isSelected ? Colors.lightBlue.withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.lightBlue : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildInitialArea() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AuthError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          );
        }

        if (state is! AuthSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64, color: Colors.lightBlue),
                const SizedBox(height: 24),
                Text(
                  "Olá, ${user.nome}!",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "O que vamos fazer hoje?",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                _buildActionButton(
                  "Criar plano de aula",
                  Icons.extension,
                  Colors.purple.shade300,
                  () => _openProfileModal("Criar plano de aula"),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  "Adaptar material",
                  Icons.assignment_add,
                  Colors.pink.shade300,
                  () => _openProfileModal("Adaptar material"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          color: Colors.white,
          boxShadow: [
             BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Envie uma mensagem para iniciar.", style: TextStyle(color: Colors.grey.shade500)),
          ],
        )
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.lightBlue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.attachedFile != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf, color: message.isUser ? Colors.white : Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.attachedFile!.name,
                            style: TextStyle(color: message.isUser ? Colors.white : Colors.black87, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.4
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 6,
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile!.name,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (text) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Digite para pesquisar',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty || _selectedFile != null) _sendMessage(val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white, size: 20),
                  onPressed: _pickFile,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 20,
                child: _isLoading 
                  ? const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(
                        _textController.text.isNotEmpty || _selectedFile != null 
                            ? Icons.send 
                            : Icons.mic, 
                        color: Colors.white, 
                        size: 20
                      ),
                      onPressed: () {
                        if (_textController.text.isNotEmpty || _selectedFile != null) {
                            _sendMessage(_textController.text);
                        } else {
                            // Implementar lógica do mic futuramente
                        }
                      },
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
