import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_adaptia/core/theme/app_colors.dart';
import 'package:projeto_adaptia/core/utils/validators.dart';
import 'package:projeto_adaptia/features/auth/domain/entities/user_entity.dart';
import 'package:projeto_adaptia/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:projeto_adaptia/features/auth/presentation/cubit/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user.nome);
    _headlineController = TextEditingController(text: widget.user.headline);
    _bioController = TextEditingController(text: widget.user.bio);
    _avatarController = TextEditingController(
      text: widget.user.avatar,
    )..addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _avatarController
      ..removeListener(_refreshPreview)
      ..dispose();
    super.dispose();
  }

  void _refreshPreview() {
    setState(() {});
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().updateProfile(
      nome: _nomeController.text.trim(),
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim(),
      avatar: _avatarController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil atualizado com sucesso.')),
            );
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        _EditableAvatarPreview(
                          imageUrl: _avatarController.text.trim(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Foto de perfil',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Informe uma URL de imagem. Se ficar vazia, usamos a foto padrao.',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProfileTextField(
                    controller: _avatarController,
                    label: 'URL da foto de perfil',
                    hintText: 'https://exemplo.com/minha-foto.jpg',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(
                    controller: _nomeController,
                    label: 'Nome',
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(
                    controller: _headlineController,
                    label: 'Headline',
                    hintText: 'Ex.: Professora de apoio inclusivo',
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(
                    controller: _bioController,
                    label: 'Biografia',
                    hintText: 'Conte um pouco sobre voce',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Salvar alteracoes'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableAvatarPreview extends StatelessWidget {
  final String imageUrl;

  const _EditableAvatarPreview({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Color(0xFFD9E8F2),
        child: Icon(Icons.person, size: 48, color: AppColors.primary),
      );
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: const Color(0xFFD9E8F2),
      child: ClipOval(
        child: Image.network(
          trimmedUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFD9E8F2),
            child: Icon(Icons.person, size: 48, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD9E8F2)),
        ),
      ),
    );
  }
}
