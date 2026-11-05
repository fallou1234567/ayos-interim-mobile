
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../features/messaging/services/messaging_service.dart';

class MessagingButton extends StatefulWidget {
  final VoidCallback onTap;

  const MessagingButton({
    super.key,
    required this.onTap,
  });

  @override
  State<MessagingButton> createState() => _MessagingButtonState();
}

class _MessagingButtonState extends State<MessagingButton> {
  int _unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _loadUnreadCount();

    // Actualisation automatique toutes les 30 secondes.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadCount(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final result = await MessagingService.getConversations();

      if (!mounted) return;

      setState(() {
        _unreadCount =
            int.tryParse(result['unread'].toString()) ?? 0;
      });
    } catch (_) {
      // Conserver le dernier compteur en cas d'erreur réseau.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      elevation: 7,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 20,
              ),

              if (_unreadCount > 0)
                Positioned(
                  top: 2,
                  right: 1,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unreadCount > 99
                          ? '99+'
                          : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
