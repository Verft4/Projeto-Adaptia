import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_adaptia/core/theme/app_colors.dart';
import 'package:projeto_adaptia/core/routes/app_routes.dart';
import 'package:projeto_adaptia/features/auth/domain/entities/user_entity.dart';
import 'package:projeto_adaptia/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:projeto_adaptia/features/auth/presentation/cubit/auth_state.dart';
import 'package:projeto_adaptia/features/auth/presentation/pages/dashboard/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<AuthCubit>().state;
              if (state is AuthSuccess) {
                _showProfileSettings(context, state.user);
              }
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuracoes do perfil',
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoggedOutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voce saiu da conta.')),
            );
            context.go(AppRoutes.login);
          } else if (state is AccountDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conta deletada com sucesso.')),
            );
            context.go(AppRoutes.login);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nao foi possivel carregar o perfil.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().loadCurrentUser(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! AuthSuccess) {
            return const SizedBox.shrink();
          }

          return _ProfileContent(user: state.user);
        },
      ),
    );
  }

  void _showProfileSettings(BuildContext context, UserEntity user) {
    final isGoogleLinked = user.googleLinked;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuracoes do perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  onTap: isGoogleLinked
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          context.read<AuthCubit>().linkGoogleAccount();
                        },
                  leading: Icon(
                    isGoogleLinked ? Icons.check_circle_outline : Icons.link,
                    color: isGoogleLinked
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57C00),
                  ),
                  title: Text(
                    isGoogleLinked
                        ? 'Conta Google vinculada'
                        : 'Vincular conta Google',
                    style: TextStyle(
                      color: isGoogleLinked
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF57C00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isGoogleLinked
                        ? 'Seu login com Google ja esta ativo'
                        : 'Permita entrar com Google nesta conta',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: isGoogleLinked
                      ? const Color(0xFFEAF7EC)
                      : const Color(0xFFFFF4E5),
                ),
                const SizedBox(height: 12),
                ListTile(
                  enabled: false,
                  leading: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade500,
                  ),
                  title: Text(
                    'Alterar senha',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: const Color(0xFFF8FBFD),
                ),
                const SizedBox(height: 12),
                ListTile(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.read<AuthCubit>().logout();
                  },
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFF1E293B),
                  ),
                  title: const Text(
                    'Deslogar da conta',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: const Color(0xFFF8FBFD),
                ),
                const SizedBox(height: 12),
                ListTile(
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final shouldDelete = await _showDeleteConfirmation(context);
                    if (shouldDelete == true && context.mounted) {
                      context.read<AuthCubit>().deleteAccount();
                    }
                  },
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Deletar conta',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Essa ação não pode ser desfeita'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: const Color(0xFFFFF5F5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deletar conta'),
          content: const Text(
            'Tem certeza que deseja deletar sua conta? Seus dados de perfil serao removidos permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final UserEntity user;

  const _ProfileContent({
    required this.user,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD9E8F2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(
                  imageUrl: user.avatar,
                  radius: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nome.trim().isEmpty ? 'Seu nome' : user.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.headline.trim().isEmpty
                            ? 'Insira sua headline'
                            : user.headline,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthCubit>(),
                      child: EditProfilePage(user: user),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar perfil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _ProfileTabButton(
                      label: 'Sobre',
                      icon: Icons.info_outline,
                      isSelected: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                    ),
                    _ProfileTabButton(
                      label: 'Destaque',
                      icon: Icons.push_pin_outlined,
                      isSelected: _selectedTabIndex == 1,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
                    _ProfileTabButton(
                      label: 'Curtidas',
                      icon: Icons.favorite_border,
                      isSelected: _selectedTabIndex == 2,
                      onTap: () => setState(() => _selectedTabIndex = 2),
                    ),
                  ],
                ),
                Container(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(user),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(UserEntity user) {
    switch (_selectedTabIndex) {
      case 1:
        return const _EmptyTabContent(
          title: 'Nenhum destaque por enquanto',
          message: 'Quando houver conteudos em destaque, eles aparecerao aqui.',
        );
      case 2:
        return const _EmptyTabContent(
          title: 'Nenhuma curtida por enquanto',
          message: 'Os itens curtidos vao aparecer aqui futuramente.',
        );
      case 0:
      default:
        final biography = user.bio.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biografia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E8F2)),
              ),
              child: Text(
                biography.isEmpty ? 'Insira sua biografia' : biography,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: biography.isEmpty
                      ? Colors.grey.shade600
                      : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _ProfileTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTabContent extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyTabContent({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E8F2)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        child: _DefaultAvatar(radius: radius),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFD9E8F2),
        child: ClipOval(
          child: Image.network(
            trimmedUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _DefaultAvatar(radius: radius),
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final double radius;

  const _DefaultAvatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD9E8F2),
      child: Icon(
        Icons.person,
        size: radius,
        color: AppColors.primary,
      ),
    );
  }
}
