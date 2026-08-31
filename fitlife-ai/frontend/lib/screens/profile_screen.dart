// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  final SyncService _sync = SyncService();
  User? _user;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _api.getProfile();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    final result = await _sync.syncAll();
    if (!mounted) return;
    setState(() => _isSyncing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppTheme.primaryDark : Colors.orangeAccent,
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final ageController = TextEditingController(text: _user!.age?.toString() ?? '');
    final weightController = TextEditingController(text: _user!.weightKg?.toString() ?? '');
    final heightController = TextEditingController(text: _user!.heightCm?.toString() ?? '');
    String goal = _user!.goal ?? 'hypertrophy';
    String activity = _user!.activityLevel ?? 'moderate';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Editar Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Idade',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Altura (cm)',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: goal,
                      decoration: InputDecoration(
                        labelText: 'Objetivo',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      dropdownColor: AppTheme.cardDarkBackground,
                      items: const [
                        DropdownMenuItem(value: 'hypertrophy', child: Text('Hipertrofia')),
                        DropdownMenuItem(value: 'weight_loss', child: Text('Emagrecimento')),
                        DropdownMenuItem(value: 'maintenance', child: Text('Manutenção')),
                      ],
                      onChanged: (val) => setModalState(() => goal = val ?? 'hypertrophy'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: activity,
                      decoration: InputDecoration(
                        labelText: 'Nível de Atividade',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      dropdownColor: AppTheme.cardDarkBackground,
                      items: const [
                        DropdownMenuItem(value: 'sedentary', child: Text('Sedentário')),
                        DropdownMenuItem(value: 'light', child: Text('Leve')),
                        DropdownMenuItem(value: 'moderate', child: Text('Moderado')),
                        DropdownMenuItem(value: 'very_active', child: Text('Muito Ativo')),
                        DropdownMenuItem(value: 'extra_active', child: Text('Extremamente Ativo')),
                      ],
                      onChanged: (val) => setModalState(() => activity = val ?? 'moderate'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await _api.updateProfile({
                            'name': nameController.text.trim(),
                            'age': int.tryParse(ageController.text),
                            'weight_kg': double.tryParse(weightController.text.replaceAll(',', '.')),
                            'height_cm': double.tryParse(heightController.text.replaceAll(',', '.')),
                            'goal': goal,
                            'activity_level': activity,
                          });
                          _loadProfile();
                        } catch (_) {}
                      },
                      child: const Text('Salvar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkBackground,
        title: const Text('Deseja sair?', style: TextStyle(color: Colors.white)),
        content: const Text('Você precisará fazer login novamente.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sair'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _api.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar e Nome
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, size: 48, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'Usuário',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cartão de Dados
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Informações Físicas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 18),
                            onPressed: _showEditProfileDialog,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      _buildProfileRow('Idade', '${user?.age ?? "--"} anos'),
                      _buildProfileRow('Sexo', user?.sex == 'female' ? 'Feminino' : 'Masculino'),
                      _buildProfileRow('Peso Atual', '${user?.weightKg ?? "--"} kg'),
                      _buildProfileRow('Altura', '${user?.heightCm ?? "--"} cm'),
                      _buildProfileRow('Objetivo', user?.goal == 'weight_loss' ? 'Emagrecimento' : 'Hipertrofia'),
                      _buildProfileRow('Nível de Atividade', user?.activityLevel ?? 'Moderado'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Botão de Sincronização
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_sync_outlined, color: AppTheme.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Sincronização Offline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Sincronizar treinos e nutrição salvos localmente', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSyncing ? null : _handleSync,
                        child: _isSyncing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Sincronizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botão Sair
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _logout,
                ),
              ],
            ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

