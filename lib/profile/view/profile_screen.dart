import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mgb/user/domain/user_model.dart';
import 'package:mgb/authentication/view/login_screen.dart';
import 'package:mgb/profile/view/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isCurrentUserProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; });

    try {
      String? userIdToLoad;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (widget.userId != null) {
        userIdToLoad = widget.userId;
        _isCurrentUserProfile = (currentUser?.uid == userIdToLoad);
      } else if (currentUser != null) {
        userIdToLoad = currentUser.uid;
        _isCurrentUserProfile = true;
      } else {
        _logout();
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(userIdToLoad).get();
      if (doc.exists && mounted) {
        setState(() {
          _userModel = UserModel.fromMap(doc.id, doc.data()!);
          _isLoading = false;
        });
      } else if(mounted) {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      if(mounted) { setState(() { _isLoading = false; }); }
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
            ? const Center(child: Text('Usuário não encontrado.', style: TextStyle(color: Colors.white)))
            : _buildProfileView(),
      ),
    );
  }

  Widget _buildProfileView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
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
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        children: [
          Center(child: Text('Conteúdo do Perfil de ${_userModel!.nickname}', style: TextStyle(color: Colors.white))),
          Center(child: Text('Conteúdo do Backlog de ${_userModel!.nickname}', style: TextStyle(color: Colors.white))),
          Center(child: Text('Conteúdo da Wishlist de ${_userModel!.nickname}', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _userModel!.nickname,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isCurrentUserProfile) // Botão só aparece no perfil do próprio usuário
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(userModel: _userModel!),
                            ),
                          ).then((_) => _loadUserData());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.grey[900], child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}