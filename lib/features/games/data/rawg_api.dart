import 'dart:convert';
import 'package:http/http.dart' as http;

class RawgApi {
  final String apiKey;
  RawgApi(this.apiKey);

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? params]) async {
    final qp = {'key': apiKey, ...?params};
    final uri = Uri.https('api.rawg.io', '/api$path', qp);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('RAWG error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> searchRaw(String query) async {
    final data = await _get('/games', {'search': query, 'page_size': '20'});
    final results = (data['results'] as List?) ?? const [];
    return results.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> detailsRaw(int id) async {
    return _get('/games/$id');
  }

  Future<List<Map<String, dynamic>>> searchGames(String query) => searchRaw(query);
  Future<Map<String, dynamic>> getGame(int id) => detailsRaw(id);
}
