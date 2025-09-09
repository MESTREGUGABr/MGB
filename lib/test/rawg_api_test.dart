import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:mgb/features/games/data/rawg_api.dart';
import 'package:mgb/features/games/domain/game_model.dart';

void main() {
  group('RawgApi', () {
    test('searchGames parses results', () async {
      final mockClient = MockClient((req) async {
        expect(req.url.path, '/api/games');
        final body = jsonEncode({
          'results': [
            {
              'id': 1,
              'name': 'The Witcher 3: Wild Hunt',
              'background_image': 'https://images.example.com/some.jpg',
              'released': '2015-05-18',
              'rating': 4.6,
              'platforms': [
                {'platform': {'name': 'PC'}},
                {'platform': {'name': 'PlayStation 4'}}
              ]
            }
          ]
        });
        return http.Response(body, 200,
            headers: {'content-type': 'application/json'});
      });

      final api = RawgApi('demo_key', client: mockClient);
      final results = await api.searchGames('witcher');
      expect(results, isA<List<GameModel>>());
      expect(results.first.name, contains('Witcher'));
      expect(results.first.platforms, contains('PC'));
    });

    test('getGame returns details', () async {
      final mockClient = MockClient((req) async {
        expect(req.url.path, '/api/games/42');
        final body = jsonEncode({
          'id': 42,
          'name': 'Example',
          'description_raw': 'A cool game',
          'background_image': null,
          'released': '2020-01-01',
          'rating': 4.2,
          'platforms': [
            {'platform': {'name': 'PC'}}
          ]
        });
        return http.Response(body, 200,
            headers: {'content-type': 'application/json'});
      });

      final api = RawgApi('demo_key', client: mockClient);
      final g = await api.getGame(42);
      expect(g.description, 'A cool game');
      expect(g.released!.year, 2020);
    });
  });
}
