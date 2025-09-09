// lib/features/games/view/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_config.dart';
import 'package:mgb/user/user_model.dart';
import 'package:mgb/user/user_repository.dart';
import 'package:mgb/profile_screen.dart';
import 'package:mgb/features/games/data/games_repository.dart';
import 'package:mgb/features/games/data/rawg_api.dart';
import 'package:mgb/features/games/domain/game_model.dart';
import 'package:mgb/search_viewmodel.dart';
import 'package:mgb/features/games/ui/game_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(
        GamesRepository(RawgApi(AppConfig.rawgApiKey)),
        UserRepository(),
      ),
      child: const _SearchScreenView(),
    );
  }
}

class _SearchScreenView extends StatefulWidget {
  const _SearchScreenView();
  @override
  State<_SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<_SearchScreenView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _doSearch() {
    FocusScope.of(context).unfocus();
    context.read<SearchViewModel>().search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Buscar jogos e usuários', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
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
                hintText: 'Digite o nickname ou nome do jogo...',
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _doSearch,
                ),
              ),
              onSubmitted: (_) => _doSearch(),
            ),
            const SizedBox(height: 12),
            if (viewModel.isLoading) const LinearProgressIndicator(),
            if (viewModel.error != null)
              Text(viewModel.error!, style: const TextStyle(color: Colors.redAccent)),

            Expanded(
              child: viewModel.results.isEmpty && !viewModel.isLoading
                  ? const Center(child: Text('Sem resultados', style: TextStyle(color: Colors.white70)))
                  : ListView.separated(
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemCount: viewModel.results.length,
                itemBuilder: (context, i) {
                  final item = viewModel.results[i];

                  if (item is GameModel) return GameListTile(game: item);
                  if (item is UserModel) return UserListTile(user: item);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameListTile extends StatelessWidget {
  final GameModel game;
  const GameListTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: game.backgroundImage != null
          ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(game.backgroundImage!, width: 56, height: 56, fit: BoxFit.cover))
          : const Icon(Icons.videogame_asset, color: Colors.white70),
      title: Text(game.name, style: const TextStyle(color: Colors.white)),
      subtitle: const Text('Jogo', style: TextStyle(color: Colors.cyan)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameDetailsScreen(gameId: game.id, initial: game),
      )),
    );
  }
}

class UserListTile extends StatelessWidget {
  final UserModel user;
  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text('Usuário • ${user.nome}', style: const TextStyle(color: Colors.amber)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: user.id),
      )),
    );
  }
}