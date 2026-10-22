import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../features/missions/data/mission_service.dart';
import '../../features/missions/models/mission_model.dart';
import '../../features/missions/screens/mission_detail_sheet.dart';

class AppNotification {
  final String id;
  final String title;
  final String detail;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? missionReference;

  const AppNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.createdAt,
    required this.readAt,
    this.missionReference,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final mission = json['mission'];

    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      detail: json['detail']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      missionReference: mission is Map
          ? mission['reference']?.toString()
          : null,
    );
  }
}

enum NotificationFilter { all, unread, missions }

class NotificationCenterSheet extends StatefulWidget {
  const NotificationCenterSheet({super.key});

  @override
  State<NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  List<AppNotification> _notifications = [];
  NotificationFilter _filter = NotificationFilter.all;

  bool _loading = true;
  bool _markingAll = false;
  String? _error;
  final MissionService _missionService = MissionService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _openMission(AppNotification notification) async {
    final reference = notification.missionReference;

    if (reference == null || reference.isEmpty) {
      await _markAsRead(notification);
      return;
    }

    try {
      final missions = await _missionService.getMissions();

      if (!mounted) return;

      MissionModel? mission;

      for (final item in missions) {
        if (item.id == reference) {
          mission = item;
          break;
        }
      }

      if (mission == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cette mission est introuvable dans votre liste.'),
          ),
        );
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return MissionDetailSheet(
            mission: mission!,
            onOpened: () => _markAsRead(notification),
            onUpdated: _loadNotifications,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir la mission : '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.instance.dio.get(
        '/missions/notifications/mine',
      );

      final data = response.data;
      if (data is! List) {
        throw Exception('Format de réponse des notifications invalide.');
      }

      final notifications = data
          .whereType<Map>()
          .map(
            (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Impossible de charger les notifications.';
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      await ApiClient.instance.dio.post(
        '/missions/notifications/${notification.id}/read',
      );

      if (!mounted) return;

      setState(() {
        final index = _notifications.indexWhere(
          (item) => item.id == notification.id,
        );

        if (index != -1) {
          final old = _notifications[index];

          _notifications[index] = AppNotification(
            id: old.id,
            title: old.title,
            detail: old.detail,
            createdAt: old.createdAt,
            readAt: DateTime.now(),
            missionReference: old.missionReference,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de marquer cette notification comme lue.'),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((item) => !item.isRead).toList();

    if (unread.isEmpty || _markingAll) return;

    setState(() => _markingAll = true);

    var failed = 0;

    for (final notification in unread) {
      try {
        await ApiClient.instance.dio.post(
          '/missions/notifications/${notification.id}/read',
        );

        if (!mounted) return;

        final index = _notifications.indexWhere(
          (item) => item.id == notification.id,
        );

        if (index != -1) {
          final old = _notifications[index];

          setState(() {
            _notifications[index] = AppNotification(
              id: old.id,
              title: old.title,
              detail: old.detail,
              createdAt: old.createdAt,
              readAt: DateTime.now(),
              missionReference: old.missionReference,
            );
          });
        }
      } catch (_) {
        failed++;
      }
    }

    if (!mounted) return;

    setState(() => _markingAll = false);

    if (failed > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$failed notification(s) n’ont pas pu être marquées comme lues.',
          ),
        ),
      );
    }
  }

  List<AppNotification> get _filteredNotifications {
    switch (_filter) {
      case NotificationFilter.unread:
        return _notifications.where((item) => !item.isRead).toList();

      case NotificationFilter.missions:
        return _notifications
            .where((item) => item.missionReference != null)
            .toList();

      case NotificationFilter.all:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDate);

    if (difference.inMinutes < 1) return 'À l’instant';
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    }
    if (now.year == localDate.year &&
        now.month == localDate.month &&
        now.day - localDate.day == 1) {
      return 'Hier';
    }

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF193B7A);
    const muted = Color(0xFF8191A8);

    final items = _filteredNotifications;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202D43),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markingAll ? null : _markAllAsRead,
                    child: Text(
                      _markingAll ? 'En cours...' : 'Tout lire',
                      style: const TextStyle(color: navy),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton('Toutes', NotificationFilter.all),
                  _filterButton('Non lues', NotificationFilter.unread),
                  _filterButton('Missions', NotificationFilter.missions),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadNotifications,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : items.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucune notification dans cette catégorie.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return Material(
                            color: item.isRead
                                ? Colors.white
                                : const Color(0xFFF0F5FF),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _openMission(item),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8EEFA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        color: navy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: item.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.bold,
                                              color: const Color(0xFF202D43),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            item.detail,
                                            style: const TextStyle(
                                              color: Color(0xFF5E6B80),
                                            ),
                                          ),
                                          if (item.missionReference !=
                                              null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Mission ${item.missionReference}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: navy,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 7),
                                          Text(
                                            _formatDate(item.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!item.isRead)
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          left: 8,
                                        ),
                                        child: Icon(
                                          Icons.circle,
                                          size: 9,
                                          color: navy,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_unreadCount notification(s) non lue(s)',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadNotifications,
                    child: const Text('Actualiser'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label, NotificationFilter filter) {
    final selected = _filter == filter;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextButton(
          onPressed: () => setState(() => _filter = filter),
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? const Color(0xFFE8EEFA)
                : Colors.transparent,
            foregroundColor: selected
                ? const Color(0xFF193B7A)
                : const Color(0xFF8191A8),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
