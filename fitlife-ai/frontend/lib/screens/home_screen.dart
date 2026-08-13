import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onStartPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bem-vindo ao FitLife AI! Em breve novas telas.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAlignment.center,
            children: [
              const Spacer(),
              // Ícone / Badge de destaque
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // Nome do aplicativo
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.extrabold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Descrição curta e moderna
              Text(
                'Sua jornada de saúde, treinos e acompanhamento físico com tecnologia inteligente.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // Botão Começar
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Começar',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => _onStartPressed(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
