class UserModel {
  String id;
  String nome;
  String nickname;
  String email;
  DateTime dataNascimento;
  String? avatarUrl;
  String? sexo;

  UserModel({
    required this.id,
    required this.nome,
    required this.nickname,
    required this.email,
    required this.dataNascimento,
    this.avatarUrl,
    this.sexo,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'nickname': nickname,
      'email': email,
      'dataNascimento': dataNascimento.toIso8601String(),
      'avatarUrl': avatarUrl,
      'sexo': sexo,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      nome: map['nome'],
      nickname: map['nickname'],
      email: map['email'],
      dataNascimento: DateTime.parse(map['dataNascimento']),
      avatarUrl: map['avatarUrl'],
      sexo: map['sexo'],
    );
  }
}