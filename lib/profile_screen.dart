import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_model.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _logout();
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userModel = UserModel.fromMap(doc.id, doc.data()!);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tratar erro
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : _userModel == null
            ? const Center(child: Text('Não foi possível carregar o perfil.', style: TextStyle(color: Colors.white)))
            : _buildProfileView(),
      ),
    );
  }

  // Novo método para construir a visualização complexa do perfil
  Widget _buildProfileView() {
    // NestedScrollView é ideal para um cabeçalho fixo com conteúdo rolável abaixo
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
              ],
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              const TabBar(
                tabs: [
                  Tab(text: 'Perfil'),
                  Tab(text: 'Backlog'),
                  Tab(text: 'Wishlist'),
                ],
                indicatorColor: Colors.red,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
            ),
            pinned: true, // Faz a TabBar "grudar" no topo ao rolar a tela
          ),
        ];
      },
      body: TabBarView(
        children: [
          // Conteúdo da Aba "Perfil"
          // Aqui entrarão as listas de jogos (Favoritos, Recentes, etc.) no futuro
          Center(child: Text('Conteúdo do Perfil', style: TextStyle(color: Colors.white))),

          // Conteúdo da Aba "Backlog"
          Center(child: Text('Conteúdo do Backlog', style: TextStyle(color: Colors.white))),

          // Conteúdo da Aba "Wishlist"
          Center(child: Text('Conteúdo da Wishlist', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // Widget para o cabeçalho (Foto, Nome, Stats, Config)
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar do Usuário
          CircleAvatar(
            radius: 40,
            backgroundImage: _userModel!.avatarUrl != null
                ? NetworkImage(_userModel!.avatarUrl!)
                : null,
            child: _userModel!.avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),

          const SizedBox(width: 20),
          // Coluna com Nome, Stats e Config
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nickname do usuário
                    Text(
                      _userModel!.nickname,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    // Botão de Configurações
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userModel: _userModel!),
                          ),
                        ).then((_) {
                          setState(() {
                            _loadUserData();
                          });
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Linha com os Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn('Seguindo', '0'),
                    _buildStatColumn('Seguidores', '0'),
                    _buildStatColumn('Jogos', '0'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar as colunas de estatísticas
  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Classe auxiliar para fazer a TabBar "grudar" no topo (pinned)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[900], // Cor de fundo da TabBar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}