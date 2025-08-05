import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_model.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nicknameController = TextEditingController();
  final _nomeRealController = TextEditingController();
  final _diaController = TextEditingController();
  final _mesController = TextEditingController();
  final _anoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _cadastrar() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );

      DateTime dataNascimento = DateTime(
        int.parse(_anoController.text),
        int.parse(_mesController.text),
        int.parse(_diaController.text),
      );

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        nome: _nomeRealController.text,
        nickname: _nicknameController.text,
        email: _emailController.text,
        dataNascimento: dataNascimento,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      Navigator.of(context).pop();

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Cadastro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logotitle.png',
                color: Colors.red,
                height: 200,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_nicknameController, 'Nome de usuário'),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(_nomeRealController, 'Nome Real'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campos de Data de Nascimento
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_diaController, 'Dia', keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(_mesController, 'Mês', keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(_anoController, 'Ano', keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campo de E-mail
              _buildTextField(_emailController, 'E-mail', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              // Campo de Senha
              _buildTextField(_senhaController, 'Senha', obscureText: true),
              const SizedBox(height: 40),
              // Botão Cadastrar
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}