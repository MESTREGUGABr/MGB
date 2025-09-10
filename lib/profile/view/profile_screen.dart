import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mgb/user/domain/user_model.dart';
import 'package:mgb/authentication/view/login_screen.dart';
import 'package:mgb/profile/view/edit_profile_screen.dart';
import 'package:mgb/features/library/data/library_repository.dart';
import 'package:mgb/features/library/domain/library_entry.dart';
import 'package:mgb/features/games/domain/game_model.dart';
import 'package:mgb/features/games/ui/game_details_screen.dart';

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
  late LibraryRepository _libraryRepo;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

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

      _libraryRepo = LibraryRepository(
        db: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      );

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userIdToLoad).get();
      if (doc.exists && mounted) {
        setState(() {
          _userModel = UserModel.fromMap(doc.id, doc.data()!);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Widget _buildGamesList(String status) {
    final streamQuery = _isCurrentUserProfile
        ? _libraryRepo.streamByStatus(status)
        : FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId ?? _userModel!.id)
            .collection('library')
            .where('status', isEqualTo: status)
            .orderBy('updatedAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map((d) => LibraryEntry.fromMap(d.data())).toList());

    return StreamBuilder<List<LibraryEntry>>(
      stream: streamQuery,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro ao carregar: ${snap.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          );
        }
        final data = snap.data ?? const [];
        if (data.isEmpty) {
          return _emptyState(status);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (_, i) => _buildGameTile(data[i]),
        );
      },
    );
  }

  Widget _buildGamesListMulti(List<String> statuses) {
    final uid = _isCurrentUserProfile
        ? (FirebaseAuth.instance.currentUser?.uid ?? _userModel?.id)
        : (widget.userId ?? _userModel!.id);

    final streamQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('library')
        .where('status', whereIn: statuses)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => LibraryEntry.fromMap(d.data())).toList());

    return StreamBuilder<List<LibraryEntry>>(
      stream: streamQuery,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro ao carregar: ${snap.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          );
        }
        final data = snap.data ?? const [];
        if (data.isEmpty) {
          return _emptyState('backlog');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (_, i) => _buildGameTile(data[i]),
        );
      },
    );
  }

  Widget _emptyState(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videogame_asset_off, size: 60, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text('Nenhum jogo em $label', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGameTile(LibraryEntry entry) {
    return ListTile(
      leading: entry.backgroundImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                entry.backgroundImage!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.videogame_asset, color: Colors.white70),
              ),
            )
          : const Icon(Icons.videogame_asset, color: Colors.white70),
      title: Text(entry.name, style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: List.generate(5, (i) {
          final filled = i < entry.rating;
          return Icon(
            filled ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber,
          );
        }),
      ),
      onTap: () {
        final initial = GameModel(
          id: entry.gameId,
          name: entry.name,
          backgroundImage: entry.backgroundImage,
          platforms: const [],
        );
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GameDetailsScreen(
            gameId: entry.gameId,
            initial: initial,
          ),
        ));
      },
    );
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
                ? const Center(
                    child: Text('Usuário não encontrado.',
                        style: TextStyle(color: Colors.white)))
                : _buildProfileView(),
      ),
    );
  }

  Widget _buildProfileView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: _buildProfileHeader()),
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 60, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text('Perfil de ${_userModel!.nickname}',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Em breve: estatísticas e atividades',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
          _buildGamesListMulti(const ['backlog', 'playing', 'finished', 'dropped']),
          _buildGamesList('wishlist'),
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
            backgroundImage:
                _userModel!.avatarUrl != null ? NetworkImage(_userModel!.avatarUrl!) : null,
            child:
                _userModel!.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
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
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isCurrentUserProfile)
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (context) => EditProfileScreen(userModel: _userModel!),
                              ))
                              .then((_) => _loadUserData());
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
        Text(value,
            style:
                const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
