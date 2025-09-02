import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../data/games_repository.dart';
import '../data/rawg_api.dart';
import '../domain/game_model.dart';

class GameDetailsScreen extends StatefulWidget {
  final int gameId;
  final GameModel? initial;

  const GameDetailsScreen({
    super.key,
    required this.gameId,
    this.initial,
  });

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late final GamesRepository _repo;
  GameModel? _game;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = GamesRepository(RawgApi(AppConfig.rawgApiKey));
    _game = widget.initial;
    _load();
  }

  Future<void> _load() async {
    try {
      final details = await _repo.details(widget.gameId);
      if (!mounted) return;
      setState(() {
        _game = details;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(game?.name ?? 'Detalhes', style: const TextStyle(color: Colors.white)),
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
              : _DetailsBody(game: game!),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add to Backlog: implementar ação')),
                      );
                    },
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Add to Backlog'),
                  ),
                ),
              ),
            ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final GameModel game;
  const _DetailsBody({required this.game});

  @override
  Widget build(BuildContext context) {
    final chips = game.platforms.take(6).map((p) {
      return Chip(
        label: Text(p, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A2A2A),
        side: BorderSide.none,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.backgroundImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                game.backgroundImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            game.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (game.released != null)
                Text(
                  'Release: ${game.released!.toLocal().toString().split(' ').first}',
                  style: const TextStyle(color: Colors.white70),
                ),
              if (game.released != null && game.rating != null)
                const Text('  •  ', style: TextStyle(color: Colors.white38)),
              if (game.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text('${game.rating}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (chips.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips,
            ),
          const SizedBox(height: 16),
          Text(
            game.description?.trim().isNotEmpty == true ? game.description! : 'Sem descrição.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
