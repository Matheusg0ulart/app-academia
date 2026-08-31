// lib/screens/main_navigation_screen.dart

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'workouts_screen.dart';
import 'nutrition_screen.dart';
import 'evolution_screen.dart';
import 'ai_assistant_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onTabChange: _onTabTapped),
      const WorkoutsScreen(),
      const NutritionScreen(),
      const EvolutionScreen(),
      const AiAssistantScreen(),
    ];

    final titles = [
      'FitLife AI',
      'Minhas Fichas de Treino',
      'Diário Nutricional',
      'Acompanhamento de Evolução',
      'FitLife AI Assistente',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              titles[_currentIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: AppTheme.primaryColor),
            tooltip: 'Calculadoras TMB / MET',
            onPressed: () => Navigator.pushNamed(context, '/calculators'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            tooltip: 'Meu Perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDarkBackground,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardDarkBackground,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Treinos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded),
              label: 'Nutrição',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'Evolução',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'FitLife AI',
            ),
          ],
        ),
      ),
    );
  }
}

