import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../games/domain/game_model.dart';
import '../../games/ui/game_details_screen.dart';
import '../data/library_repository.dart';
import '../domain/library_entry.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LibraryRepository _repo;

  static const statuses = ['wishlist', 'backlog', 'playing', 'finished', 'dropped'];
  static const labels = ['Wishlist', 'Backlog', 'Playing', 'Finished', 'Dropped'];

  @override
  void initState() {
    super.initState();
    _repo = LibraryRepository(db: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
    _tabController = TabController(length: statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEntryTile(LibraryEntry e) {
    return ListTile(
      leading: e.backgroundImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(e.backgroundImage!, width: 56, height: 56, fit: BoxFit.cover),
            )
          : const Icon(Icons.videogame_asset, color: Colors.white70),
      title: Text(e.name, style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: List.generate(5, (i) {
          final filled = i < e.rating;
          return Icon(filled ? Icons.star : Icons.star_border, size: 18, color: Colors.amber);
        }),
      ),
      onTap: () {
        final initial = GameModel(
          id: e.gameId,
          name: e.name,
          backgroundImage: e.backgroundImage,
          platforms: const [],
        );
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GameDetailsScreen(gameId: e.gameId, initial: initial),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My Library', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [for (final l in labels) Tab(text: l)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final status in statuses)
            StreamBuilder<List<LibraryEntry>>(
              stream: _repo.streamByStatus(status),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snap.data ?? const [];
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Lista vazia', style: TextStyle(color: Colors.white70)),
                  );
                }
                return ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                  itemBuilder: (_, i) => _buildEntryTile(data[i]),
                );
              },
            ),
        ],
      ),
    );
  }
}
