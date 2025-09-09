// lib/features/games/viewmodel/search_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:mgb/user/data/user_repository.dart';
import 'package:mgb/features/games/data/games_repository.dart'; // Você já tem este

class SearchViewModel extends ChangeNotifier {
  final GamesRepository _gamesRepo;
  final UserRepository _userRepo;

  SearchViewModel(this._gamesRepo, this._userRepo);

  List<Object> _results = [];
  bool _isLoading = false;
  String? _error;

  List<Object> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final futureGames = _gamesRepo.search(trimmedQuery);
      final futureUsers = _userRepo.search(trimmedQuery);

      final responses = await Future.wait([futureUsers, futureGames]);

      final userResults = responses[0];
      final gameResults = responses[1];

      _results = [...userResults, ...gameResults];
    } catch (e) {
      _error = 'Ocorreu um erro na busca.';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}