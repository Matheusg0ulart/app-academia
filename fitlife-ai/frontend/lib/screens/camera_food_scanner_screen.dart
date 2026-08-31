// lib/screens/camera_food_scanner_screen.dart
//
// Scanner Visual de Prato com Gemini Vision AI
// Captura foto pela câmera ou galeria, envia ao backend e exibe análise nutricional completa

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class CameraFoodScannerScreen extends StatefulWidget {
  const CameraFoodScannerScreen({super.key});

  @override
  State<CameraFoodScannerScreen> createState() => _CameraFoodScannerScreenState();
}

class _CameraFoodScannerScreenState extends State<CameraFoodScannerScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Map<String, dynamic>? _analysis;
  bool _isAnalyzing = false;
  String _errorMessage = '';
  final Set<int> _addedItems = {};

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _analysis = null;
        _errorMessage = '';
        _addedItems.clear();
      });

      await _analyzeImage();
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao acessar câmera/galeria: $e');
    }
  }

  Future<void> _analyzeImage() async {
    final img = _selectedImage;
    if (img == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      final bytes = await img.readAsBytes();
      final base64Image = base64Encode(bytes);

      final data = await _api.scanFoodPlate(base64Image: base64Image);
      if (!mounted) return;
      setState(() {
        _analysis = data['analysis'] as Map<String, dynamic>?;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.toString().contains('GEMINI_API_KEY')
            ? '⚠️ Configure sua chave Gemini em backend/.env\n(GEMINI_API_KEY=sua_chave_aqui)'
            : 'Erro ao analisar a imagem. Verifique sua conexão e tente novamente.';
      });
    }
  }

  Future<void> _addItemToDiary(int index, Map<String, dynamic> item) async {
    try {
      await _api.logMeal({
        'meal_type': 'other',
        'description': item['name'] ?? 'Alimento escaneado',
        'calories_kcal': (item['calories'] as num?)?.toDouble() ?? 0,
        'protein_g': (item['protein'] as num?)?.toDouble() ?? 0,
        'carbs_g': (item['carbs'] as num?)?.toDouble() ?? 0,
        'fat_g': (item['fat'] as num?)?.toDouble() ?? 0,
      });
      if (!mounted) return;
      setState(() => _addedItems.add(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${item['name']} adicionado ao diário!'),
          backgroundColor: AppTheme.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }

  Future<void> _addAllToDiary() async {
    final items = (_analysis?['items'] as List<dynamic>? ?? []);
    for (int i = 0; i < items.length; i++) {
      if (!_addedItems.contains(i)) {
        await _addItemToDiary(i, items[i] as Map<String, dynamic>);
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🍽️ Todos os itens adicionados ao diário!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _confidenceColor(String? confidence) {
    switch (confidence) {
      case 'alta':
        return Colors.greenAccent;
      case 'média':
        return Colors.amberAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Color _healthScoreColor(int score) {
    if (score >= 8) return Colors.greenAccent;
    if (score >= 5) return Colors.amberAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final items = (analysis?['items'] as List<dynamic>? ?? []);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Scanner de Prato com IA 🔍'),
        actions: [
          if (analysis != null && items.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.playlist_add_rounded, color: AppTheme.primaryColor),
              label: const Text('Tudo no Diário', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _addAllToDiary,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Área da Imagem ──────────────────────────────────────────
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover),
                          if (_isAnalyzing)
                            Container(
                              color: Colors.black.withOpacity(0.6),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 3),
                                  SizedBox(height: 12),
                                  Text('Gemini AI analisando o prato...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Identificando alimentos e estimando porções', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_enhance_rounded, color: AppTheme.primaryColor, size: 48),
                          ),
                          const SizedBox(height: 14),
                          const Text('Toque para fotografar ou importar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('O Gemini AI identificará os alimentos e estimará as calorias', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Botões de Câmera / Galeria ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Câmera', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Galeria', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Erro ───────────────────────────────────────────────────
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12, height: 1.5)),
              ),

            // ── Resultados da Análise ───────────────────────────────────
            if (analysis != null) ...[
              // Card Descrição & Score de Saúde
              GlassCard(
                borderColor: AppTheme.primaryColor.withOpacity(0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analysis['plateDescription'] as String? ?? 'Prato analisado',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroCard('CALORIAS', '${analysis['totalCalories'] ?? 0}', 'kcal', Colors.orangeAccent),
                        _buildMacroCard('PROTEÍNA', '${(analysis['totalProtein'] as num?)?.toStringAsFixed(1) ?? 0}', 'g', Colors.blueAccent),
                        _buildMacroCard('CARBOS', '${(analysis['totalCarbs'] as num?)?.toStringAsFixed(1) ?? 0}', 'g', Colors.amberAccent),
                        _buildMacroCard('GORDURA', '${(analysis['totalFat'] as num?)?.toStringAsFixed(1) ?? 0}', 'g', Colors.pinkAccent),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Score de Saúde:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Row(
                          children: [
                            ...List.generate(10, (i) {
                              final score = (analysis['healthScore'] as num?)?.toInt() ?? 5;
                              return Icon(
                                i < score ? Icons.circle : Icons.circle_outlined,
                                color: _healthScoreColor(score),
                                size: 10,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              '${analysis['healthScore']}/10',
                              style: TextStyle(
                                color: _healthScoreColor((analysis['healthScore'] as num?)?.toInt() ?? 5),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Itens Identificados
              const Text('🔍 Alimentos Identificados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              ...items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value as Map<String, dynamic>;
                final isAdded = _addedItems.contains(i);
                final confidence = item['confidence'] as String? ?? 'média';

                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item['calories'] ?? 0}\nkcal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 10, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] as String? ?? 'Alimento',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _confidenceColor(confidence).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(confidence, style: TextStyle(color: _confidenceColor(confidence), fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['portionDescription'] as String? ?? '',
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'P: ${(item['protein'] as num?)?.toStringAsFixed(1) ?? 0}g  •  C: ${(item['carbs'] as num?)?.toStringAsFixed(1) ?? 0}g  •  G: ${(item['fat'] as num?)?.toStringAsFixed(1) ?? 0}g',
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isAdded ? Colors.greenAccent : AppTheme.primaryColor,
                          size: 26,
                        ),
                        tooltip: isAdded ? 'Adicionado!' : 'Adicionar ao Diário',
                        onPressed: isAdded ? null : () => _addItemToDiary(i, item),
                      ),
                    ],
                  ),
                );
              }),

              // Observações da IA
              if ((analysis['observations'] as String? ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                GlassCard(
                  borderColor: Colors.white12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 16),
                          SizedBox(width: 6),
                          Text('Observações do Nutricionista IA', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis['observations'] as String? ?? '',
                        style: TextStyle(color: Colors.grey[300], fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 70),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text('Escolher Imagem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor),
              title: const Text('Câmera', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Fotografar o prato agora', style: TextStyle(color: Colors.grey, fontSize: 11)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryColor),
              title: const Text('Galeria de Fotos', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Selecionar uma foto existente', style: TextStyle(color: Colors.grey, fontSize: 11)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17)),
        Text(unit, style: TextStyle(color: Colors.grey[500], fontSize: 9)),
      ],
    );
  }
}
