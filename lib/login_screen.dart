import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'recuperar_senha_screen.dart';
import 'main_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      //...
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logotitle.png',
                color: Colors.red,
                height: 200,
              ),
              const SizedBox(height: 50),
              // Campo de E-mail
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Campo de Senha
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              // Botão Entrar
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RecuperarSenhaScreen()),
                  );
                },
                child: const Text(
                  'Esqueci a senha',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (context) => CadastroScreen()));
                },
                child: const Text(
                  'Criar uma conta nova',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}