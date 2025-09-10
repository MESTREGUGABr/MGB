import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/app_config.dart';
import '../data/games_repository.dart';
import '../data/rawg_api.dart';
import '../domain/game_model.dart';
import '../../library/data/library_repository.dart';

class GameDetailsScreen extends StatefulWidget {
  final int gameId;
  final GameModel? initial;
  const GameDetailsScreen({super.key, required this.gameId, this.initial});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late final GamesRepository _gamesRepo;
  late final LibraryRepository _libraryRepo;
  GameModel? _game;
  bool _loading = true;
  String? _error;
  int _rating = 0;
  String? _currentStatus;

  @override
  void initState() {
    super.initState();
    _gamesRepo = GamesRepository(RawgApi(AppConfig.rawgApiKey));
    _libraryRepo = LibraryRepository(db: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
    _game = widget.initial;
    _load();
  }

  Future<void> _load() async {
    try {
      final details = await _gamesRepo.details(widget.gameId);
      if (!mounted) return;
      setState(() {
        _game = details;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _saveTo(String status) async {
    if (_game == null) return;
    try {
      await _libraryRepo.upsertEntry(game: _game!, status: status, rating: _rating);
      if (!mounted) return;
      setState(() => _currentStatus = status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Salvo em $status')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _setStage(String status) async {
    try {
      await _libraryRepo.setStatus(widget.gameId, status);
      if (!mounted) return;
      setState(() => _currentStatus = status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: $status')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _setRating(int value) async {
    try {
      setState(() => _rating = value);
      await _libraryRepo.setRating(widget.gameId, value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Widget _stars() {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        return IconButton(
          icon: Icon(n <= _rating ? Icons.star : Icons.star_border, color: Colors.amber),
          onPressed: () => _setRating(n),
        );
      }),
    );
  }

  Widget _stageChips() {
    final statuses = ['playing', 'finished', 'dropped'];
    return Wrap(
      spacing: 8,
      children: statuses
          .map((s) => ChoiceChip(label: Text(s), selected: _currentStatus == s, onSelected: (_) => _setStage(s)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = _game;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(g?.name ?? 'Detalhes', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (g?.backgroundImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(g!.backgroundImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 16),
                    Text(g!.name,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (g.released != null)
                        Text('Release: ${g.released!.toLocal().toString().split(' ').first}',
                            style: const TextStyle(color: Colors.white70)),
                      if (g.released != null && g.rating != null)
                        const Text('  •  ', style: TextStyle(color: Colors.white38)),
                      if (g.rating != null)
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${g.rating}', style: const TextStyle(color: Colors.white70)),
                        ]),
                    ]),
                    const SizedBox(height: 12),
                    if (g.platforms.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: g.platforms
                            .take(6)
                            .map((p) => Chip(
                                  label: Text(p, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: const Color(0xFF2A2A2A),
                                  side: BorderSide.none,
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      g.description?.trim().isNotEmpty == true ? g.description! : 'Sem descrição.',
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    const Text('Sua avaliação', style: TextStyle(color: Colors.white)),
                    _stars(),
                    const SizedBox(height: 8),
                    const Text('Stage', style: TextStyle(color: Colors.white)),
                    _stageChips(),
                    const SizedBox(height: 120),
                  ]),
                ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => _saveTo('wishlist'),
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Add to Wishlist'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => _saveTo('backlog'),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Add to Backlog'),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}
