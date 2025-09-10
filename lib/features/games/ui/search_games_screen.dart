import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../data/games_repository.dart';
import '../data/rawg_api.dart';
import '../domain/game_model.dart';
import 'game_details_screen.dart';

class SearchGamesScreen extends StatefulWidget {
  const SearchGamesScreen({super.key});

  @override
  State<SearchGamesScreen> createState() => _SearchGamesScreenState();
}

class _SearchGamesScreenState extends State<SearchGamesScreen> {
  final _controller = TextEditingController();
  late final GamesRepository _repo;
  List<GameModel> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = GamesRepository(RawgApi(AppConfig.rawgApiKey));
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    if (!AppConfig.hasRawgKey) {
      setState(() => _error = 'RAWG_API_KEY ausente');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final r = await _repo.search(q);
      setState(() => _results = r);
    } catch (e) {
      setState(() => _error = 'Falha na busca: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Buscar jogos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome...',
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Sem resultados', style: TextStyle(color: Colors.white70)))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                      itemBuilder: (_, i) {
                        final g = _results[i];
                        return ListTile(
                          leading: g.backgroundImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(g.backgroundImage!, width: 56, height: 56, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.videogame_asset, color: Colors.white70),
                          title: Text(g.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            [
                              if (g.released != null)
                                'Lançamento: ${g.released!.toLocal().toString().split(' ').first}',
                              if (g.rating != null) 'Nota: ${g.rating}',
                              if (g.platforms.isNotEmpty) 'Plataformas: ${g.platforms.take(3).join(', ')}',
                            ].join(' • '),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => GameDetailsScreen(gameId: g.id, initial: g),
                            ));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
