import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'user/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({super.key, required this.userModel});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserModel _currentUserModel;

  @override
  void initState() {
    super.initState();
    _currentUserModel = widget.userModel;
  }

  Future<void> _showEditUsernameDialog() async {
    final newUsernameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Alterar nome de usuário', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: newUsernameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Digite o novo nome", hintStyle: TextStyle(color: Colors.grey)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Salvar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final newUsername = newUsernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'nickname': newUsername,
                    });
                    setState(() {
                      _currentUserModel.nickname = newUsername;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Tratar erro
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetPasswordConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Alterar Senha', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Enviaremos um link para o seu e-mail para que você possa criar uma nova senha com segurança. Deseja continuar?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sim, Enviar E-mail', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser!;
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-mail de redefinição enviado!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  // Tratar erro
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEmailDialog() async {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Alterar E-mail", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newEmailController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Novo e-mail", labelStyle: TextStyle(color: Colors.grey)),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Senha atual", labelStyle: TextStyle(color: Colors.grey)),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Salvar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                final newEmail = newEmailController.text.trim();
                final password = passwordController.text.trim();

                if (user == null || newEmail.isEmpty || password.isEmpty) return;

                // Mostra um indicador de carregamento
                showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)), barrierDismissible: false);

                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );

                  await user.reauthenticateWithCredential(credential);

                  await user.verifyBeforeUpdateEmail(newEmail);

                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'email': newEmail,
                  });

                  // Atualiza o estado local para a UI refletir a mudança
                  setState(() {
                    _currentUserModel.email = newEmail;
                  });

                  Navigator.of(context).pop(); // Fecha o indicador de loading
                  Navigator.of(context).pop(); // Fecha o AlertDialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-mail de verificação enviado para o novo endereço!'), backgroundColor: Colors.green),
                  );

                } on FirebaseAuthException catch (e) {
                  Navigator.of(context).pop(); // Fecha o indicador de loading
                  String errorMsg = "Ocorreu um erro.";
                  if (e.code == 'wrong-password') {
                    errorMsg = "A senha atual está incorreta.";
                  } else if (e.code == 'email-already-in-use') {
                    errorMsg = "Este e-mail já está em uso por outra conta.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(_currentUserModel.nickname, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Seção da Foto de Perfil ---
            GestureDetector(
              onTap: () {
                // TODO: Implementar lógica para alterar foto
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _currentUserModel.avatarUrl != null
                        ? NetworkImage(_currentUserModel.avatarUrl!)
                        : null,
                    child: _currentUserModel.avatarUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Clique para alterar',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Seção de Informações ---
            _buildInfoRow(
              label: 'Nome de usuário:',
              value: _currentUserModel.nickname,
              onEdit: _showEditUsernameDialog,
            ),
            const Divider(color: Colors.grey, height: 30),
            _buildInfoRow(
              label: 'E-mail:',
              value: _currentUserModel.email,
              onEdit: _showEditEmailDialog,
            ),
            const Divider(color: Colors.grey, height: 30),
            _buildInfoRow(
              label: 'Senha:',
              value: '************',
              onEdit: _showResetPasswordConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text(value, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),
        TextButton(
          onPressed: onEdit,
          child: const Text('Editar', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      ],
    );
  }
}