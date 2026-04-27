class UserEntity {
  final String id;
  final String email;
  final String nome;
  final String headline;
  final String bio;
  final String avatar;
  final bool googleLinked;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nome,
    this.headline = '',
    this.bio = '',
    this.avatar = '',
    this.googleLinked = false,
  });
}
