// lib/screens/ai_assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../models/ai_message.dart';
import '../services/api_service.dart';
import '../widgets/ai_pulse_avatar.dart';
import '../widgets/glass_card.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isSending = false;

  final List<Map<String, dynamic>> _quickPrompts = [
    {'label': '⏱️ Tenho apenas 30 min', 'text': 'Tenho apenas 30 minutos para treinar hoje.'},
    {'label': '🥗 Calorias consumidas hoje', 'text': 'Quantas calorias eu consumi hoje?'},
    {'label': '📈 Como foi minha evolução?', 'text': 'Como foi minha evolução e progresso no aplicativo?'},
    {'label': '🏋️‍♂️ Dicas para Supino', 'text': 'Dicas de execução para o Supino Reto com Barra'},
    {'label': '🥑 Explique meus macros', 'text': 'Explique minha meta de macronutrientes e calorias de hoje.'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(AiMessage.assistant(
      'Olá! Sou o **FitLife AI**, seu assistente inteligente integrado.\n\n'
      'Posso analisar seus treinos, calcular as calorias registradas hoje, sugerir rotinas para quando tiver pouco tempo e tirar dúvidas de execução de exercícios com segurança.\n\n'
      'Como posso te ajudar agora?',
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _messages.add(AiMessage.user(query));
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final res = await _api.sendChatMessage(query);
      if (!mounted) return;
      setState(() {
        _messages.add(AiMessage.assistant(res['reply'] as String, source: res['source'] as String?));
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(AiMessage.assistant(
          'Desculpe, não consegui me comunicar com o servidor no momento. Verifique sua conexão com a API.',
        ));
        _isSending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mensagem copiada para a área de transferência!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AiPulseAvatar(size: 28),
            SizedBox(width: 10),
            Text('FitLife AI Assistente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chips de Sugestões Rápidas com ícones
          Container(
            height: 48,
            color: AppTheme.darkBackground,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppTheme.cardDarkBackground,
                    label: Text(
                      prompt['label']!,
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    onPressed: () => _sendMessage(prompt['text']!),
                  ),
                );
              },
            ),
          ),

          // Lista de Mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isSending) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                  ),
                  SizedBox(width: 10),
                  Text('FitLife AI está analisando seus dados...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],

          // Campo de Entrada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkBackground,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Pergunte sobre treinos, calorias ou execução...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 30),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDarkBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 14),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'FitLife AI',
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copiar resposta',
                  onPressed: () => _copyToClipboard(msg.text),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
