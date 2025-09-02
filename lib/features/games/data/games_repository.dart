import 'rawg_api.dart';
import '../domain/game_model.dart';

class GamesRepository {
  final RawgApi api;
  GamesRepository(this.api);

  Future<List<GameModel>> search(String query) => api.searchGames(query);
  Future<GameModel> details(int id) => api.getGame(id);
}
