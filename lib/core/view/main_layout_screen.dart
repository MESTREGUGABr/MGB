// lib/main_layout_screen.dart

import 'package:flutter/material.dart';
import '../../home_screen.dart';
import '../../profile/view/profile_screen.dart';
import 'package:mgb/profile/view/search_screen.dart';
import 'package:mgb/features/games/ui/search_games_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});
  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomeScreen(),          // Tela no Índice 0
    const _FeedPlaceholder(),    // Tela no Índice 1
    const SearchGamesScreen(),   // Tela no Índice 2
    const SearchScreen(),        // Tela no Índice 3
    const ProfileScreen(),       // Tela no Índice 4
  ];

  void _onBottomItemTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            label: 'Home', icon: Icons.home_rounded,
            selected: _selectedIndex == 0, onTap: () => _onBottomItemTap(0),
          ),
          _NavItem(
            label: 'Feed', icon: Icons.bolt_rounded,
            selected: _selectedIndex == 1, onTap: () => _onBottomItemTap(1),
          ),
          _buildCenterAddButton(),
          _NavItem(
            label: 'Buscar', icon: Icons.search_rounded,
            selected: _selectedIndex == 3, onTap: () => _onBottomItemTap(3),
          ),
          _NavItem(
            label: 'Perfil', icon: Icons.person_rounded,
            selected: _selectedIndex == 4, onTap: () => _onBottomItemTap(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return InkWell(
      onTap: () => _onBottomItemTap(2),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _FeedPlaceholder extends StatelessWidget {
  const _FeedPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('Feed', style: TextStyle(color: Colors.white70))),
    );
  }
}