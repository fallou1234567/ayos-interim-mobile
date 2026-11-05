import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';
import 'package:uuid/uuid.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];

  ConversationModel? _selectedConversation;

  bool _isLoading = true;
  bool _isSending = false;
  bool _canSend = false;
  final Uuid _uuid = const Uuid();

  String? _errorMessage;

  static const int _maxLength = 4000;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT DES CONVERSATIONS
  // ============================================================

  Future<void> _loadConversations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await MessagingService.getConversations();

      final conversations = result['conversations'] as List<ConversationModel>;

      final canSend = result['canSend'] == true;

      if (!mounted) return;

      setState(() {
        _canSend = canSend;
        _selectedConversation = conversations.isNotEmpty
            ? conversations.first
            : null;
      });

      if (_selectedConversation != null) {
        await _loadMessages(_selectedConversation!.id);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _extractError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshConversations() async {
    try {
      // final result = await MessagingService.getConversations();

      if (!mounted) return;

      setState(() {
        // _conversations = result['conversations'];
      });
    } catch (e) {
      debugPrint('Erreur actualisation conversations : $e');
    }
  }

  // ============================================================
  // CHARGEMENT DES MESSAGES
  // ============================================================
  Future<void> _loadMessages(
    String conversationId, {
    bool showLoader = true,
  }) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // 1. Récupérer les messages depuis l'API
      final messages = await MessagingService.getMessages(conversationId);

      if (!mounted) return;

      // 2. Mettre à jour l'affichage
      setState(() {
        _messages = messages;
        _errorMessage = null;
      });

      // 3. Récupérer l'utilisateur connecté
      final user = context.read<AuthProvider>().user;

      // 4. Identifier les messages reçus non lus
      final unreadMessageIds = messages
          .where(
            (message) =>
                message.unreadForViewer && message.senderId != user?.id,
          )
          .map((message) => message.id)
          .toList();

      // 5. Marquer les messages comme lus
      if (unreadMessageIds.isNotEmpty) {
        try {
          await MessagingService.markAsRead(
            conversationId: conversationId,
            messageIds: unreadMessageIds,
          );

          // 6. Actualiser la liste des conversations
          await _refreshConversations();
        } catch (e) {
          debugPrint('Erreur lors du marquage des messages comme lus : $e');
        }
      }

      // 7. Descendre automatiquement vers le dernier message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de charger les messages.';
        });
      }

      debugPrint('Erreur chargement messages : $e');
    } finally {
      if (mounted && showLoader) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ENVOI D'UN MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty || _isSending) return;

    final conversation = _selectedConversation;

    if (conversation == null) return;

    final user = context.read<AuthProvider>().user;

    if (user == null || user.id.isEmpty) {
      _showSnackBar('Utilisateur non identifié.');
      return;
    }

    if (!_canSend) {
      _showSnackBar("L'envoi de messages n'est pas autorisé.");
      return;
    }

    // Identifiant unique pour ce message.
    final clientMessageId = _uuid.v4();

    setState(() {
      _isSending = true;
    });

    try {
      await MessagingService.sendMessage(
        conversationId: conversation.id,
        clientId: clientMessageId,
        content: content,
      );

      _messageController.clear();

      await _loadMessages(conversation.id, showLoader: false);

      await _refreshConversationInfo();
    } catch (e) {
      if (mounted) {
        _showSnackBar("Impossible d'envoyer le message : ${_extractError(e)}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // ACTUALISATION DES CONVERSATIONS
  // ============================================================

  Future<void> _refreshConversationInfo() async {
    try {
      final result = await MessagingService.getConversations();

      if (!mounted) return;

      final conversations = result['conversations'] as List<ConversationModel>;

      setState(() {
        // _conversations = conversations;
        _canSend = result['canSend'] == true;

        if (_selectedConversation != null) {
          for (final conversation in conversations) {
            if (conversation.id == _selectedConversation!.id) {
              _selectedConversation = conversation;
              break;
            }
          }
        }
      });
    } catch (_) {
      // Les messages déjà envoyés restent affichés.
    }
  }

  // ============================================================
  // SCROLL AUTOMATIQUE
  // ============================================================


  // ============================================================
  // FORMATAGE DES DATES
  // ============================================================

  String _formatTime(DateTime? date) {
    if (date == null) return '';

    final localDate = date.toLocal();

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final localDate = date.toLocal();
    final now = DateTime.now();

    if (localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day) {
      return "Aujourd'hui";
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (localDate.year == yesterday.year &&
        localDate.month == yesterday.month &&
        localDate.day == yesterday.day) {
      return 'Hier';
    }

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  // ============================================================
  // GESTION DES ERREURS
  // ============================================================

  String _extractError(dynamic error) {
    try {
      final response = error.response;

      if (response?.data is Map) {
        final data = Map<String, dynamic>.from(response.data);

        return data['message']?.toString() ??
            data['error']?.toString() ??
            'Une erreur est survenue.';
      }

      return error.message?.toString() ?? 'Une erreur est survenue.';
    } catch (_) {
      return 'Une erreur est survenue.';
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // CONSTRUCTION DE L'INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessageArea()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Équipe AYOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Assistance et communication',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _loadConversations,
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Fermer',
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ZONE DES MESSAGES
  // ============================================================

  Widget _buildMessageArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 45,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadConversations,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedConversation == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucune conversation disponible pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message pour le moment.\nCommencez la conversation !',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          _loadMessages(_selectedConversation!.id, showLoader: false),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];

          final previousDate = index > 0
              ? _messages[index - 1].createdAt
              : null;

          final showDate =
              index == 0 ||
              _formatDate(message.createdAt) != _formatDate(previousDate);

          return Column(
            children: [
              if (showDate) _buildDateSeparator(message.createdAt),
              _buildMessageBubble(message),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SÉPARATEUR DE DATE
  // ============================================================

  Widget _buildDateSeparator(DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE0E5ED))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE0E5ED))),
        ],
      ),
    );
  }

  // ============================================================
  // BULLE DE MESSAGE
  // ============================================================

  Widget _buildMessageBubble(MessageModel message) {
    final user = context.read<AuthProvider>().user;

    final isMine = user != null && message.senderId == user.id;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              Text(
                message.senderName.isEmpty ? 'Équipe AYOS' : message.senderName,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
            ],

            Text(
              message.content,
              style: TextStyle(
                color: isMine ? Colors.white : const Color(0xFF273449),
                fontSize: 13,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 7),

            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMine ? Colors.white60 : AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),

                if (isMine) ...[
                  const SizedBox(width: 5),
                  Icon(
                    message.read ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.read
                        ? const Color(0xFF65D6FF)
                        : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ZONE DE SAISIE
  // ============================================================

  Widget _buildMessageInput() {
    final enabled = _canSend && _selectedConversation != null && !_isSending;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        12,
        14,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8ECF2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: _maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    setState(() {});
                  },
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _canSend
                        ? 'Écrire un message...'
                        : "L'envoi de messages est désactivé.",
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 46,
                height: 46,
                child: ElevatedButton(
                  onPressed:
                      enabled && _messageController.text.trim().isNotEmpty
                      ? _sendMessage
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    disabledBackgroundColor: AppColors.navy.withValues(
                      alpha: 0.35,
                    ),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    elevation: 0,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            '${_messageController.text.length}/$_maxLength caractères',
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
