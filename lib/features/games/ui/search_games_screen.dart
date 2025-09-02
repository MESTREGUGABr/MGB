import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _doSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    if (!AppConfig.hasRawgKey) {
      setState(() {
        _error = 'RAWG_API_KEY ausente. Rode com --dart-define ou --dart-define-from-file.';
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.search(q);
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.black,
        title: const Text('Buscar jogos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do jogo...',
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _doSearch,
                ),
              ),
              onSubmitted: (_) => _doSearch(),
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
                  ? const Center(
                      child: Text('Sem resultados', style: TextStyle(color: Colors.white70)),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (context, i) {
                        final g = _results[i];
                        return ListTile(
                          leading: g.backgroundImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    g.backgroundImage!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.videogame_asset, color: Colors.white70),
                          title: Text(g.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            [
                              if (g.released != null) 'Lançamento: ${g.released!.toLocal().toString().split(' ').first}',
                              if (g.rating != null) 'Nota: ${g.rating}',
                              if (g.platforms.isNotEmpty) 'Plataformas: ${g.platforms.take(3).join(', ')}',
                            ].join(' • '),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameDetailsScreen(
                                  gameId: g.id,
                                  initial: g,
                                ),
                              ),
                            );
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
