import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/game_model.dart';

/// RAWG API client — https://rawg.io/apidocs
class RawgApi {
  final String apiKey;
  final http.Client _client;

  static const _base = 'api.rawg.io';

  RawgApi(this.apiKey, {http.Client? client})
      : _client = client ?? http.Client();

  /// Busca jogos por texto
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.https(_base, '/api/games', {
      'key': apiKey,
      'search': query,
      'page': '$page',
      'page_size': '$pageSize',
    });

    final resp =
        await _client.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200) {
      throw Exception('RAWG search failed: ${resp.statusCode} - ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List? ?? [])
        .map((e) => GameModel.fromRawg(e as Map<String, dynamic>))
        .toList()
        .cast<GameModel>();
    return results;
  }

  /// Detalhes de um jogo (traz descrição, etc.)
  Future<GameModel> getGame(int id) async {
    final uri = Uri.https(_base, '/api/games/$id', {'key': apiKey});
    final resp =
        await _client.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200) {
      throw Exception('RAWG game fetch failed: ${resp.statusCode} - ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return GameModel(
      id: data['id'],
      name: data['name'] ?? '',
      description: data['description_raw'] ?? data['description'],
      backgroundImage: data['background_image'],
      released: data['released'] != null && data['released'] != ''
          ? DateTime.tryParse(data['released'])
          : null,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : null,
      platforms: (data['platforms'] as List? ?? [])
          .map((p) => p['platform']?['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}
