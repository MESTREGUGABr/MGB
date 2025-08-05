import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Índice 0
    const Center(child: Text('Tela de Atividades', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Tela de Adicionar', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Tela de Pesquisa', style: TextStyle(color: Colors.white))),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.flash_on, 1),
          _buildNavAddItem(),
          _buildNavItem(Icons.search, 3),
          _buildNavItem(Icons.person, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, size: 30),
      color: _selectedIndex == index ? Colors.red : Colors.grey[600],
      onPressed: () => _onItemTapped(index),
    );
  }

  Widget _buildNavAddItem() {
    return InkWell(
      onTap: () => _onItemTapped(2),
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}