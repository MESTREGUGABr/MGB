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

  // Método para converter o objeto UserModel em um Map para o Firestore
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

  // Método para criar um objeto UserModel a partir de um Map do Firestore
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