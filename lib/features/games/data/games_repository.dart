import '../domain/game_model.dart';
import 'rawg_api.dart';

class GamesRepository {
  final RawgApi api;
  GamesRepository(this.api);

  Future<List<GameModel>> search(String query) async {
    final list = await api.searchRaw(query);
    return list.map((m) => GameModel.fromRawg(m)).toList();
  }

  Future<GameModel> details(int id) async {
    final map = await api.detailsRaw(id);
    return GameModel.fromRawg(map);
  }
}
