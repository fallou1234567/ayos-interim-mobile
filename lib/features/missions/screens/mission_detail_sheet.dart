import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/mission_service.dart';
import '../models/mission_model.dart';

class MissionDetailSheet extends StatefulWidget {
  final MissionModel mission;
  final Future<void> Function()? onUpdated;
  final Future<void> Function()? onOpened;

  const MissionDetailSheet({
    super.key,
    required this.mission,
    this.onUpdated,
    this.onOpened,
  });

  @override
  State<MissionDetailSheet> createState() => _MissionDetailSheetState();
}

class _MissionDetailSheetState extends State<MissionDetailSheet> {
  final MissionService _service = MissionService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  String _declineReason = 'UNAVAILABLE';
  bool _isLoading = false;

  String get _status => widget.mission.status.trim().toLowerCase();

  bool get _isProposed => _status == 'proposée' || _status == 'proposee';

  bool get _isAccepted => _status == 'acceptée' || _status == 'acceptee';

  bool get _isStarted => _status == 'en cours' || _status == 'en_cours';

  bool get _isCompleted => _status == 'terminée' || _status == 'terminee';

  DateTime get _missionStart {
    final parts = widget.mission.start.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(
      widget.mission.date.year,
      widget.mission.date.month,
      widget.mission.date.day,
      hour,
      minute,
    );
  }

  bool get _canCancel =>
      _isAccepted &&
      _missionStart.difference(DateTime.now()) > const Duration(hours: 24);

  @override
  void dispose() {
    _commentController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await widget.onOpened?.call();
      } catch (_) {
        // Une erreur de notification ne bloque pas l'ouverture
        // de la fiche de mission.
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await action();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      // Fermer la fiche après la réussite de l'action.
      Navigator.of(context).pop();

      // Actualiser la liste des missions.
      await widget.onUpdated?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _accept() async {
    final confirmed = await _confirm(
      title: 'Accepter cette mission ?',
      message: 'Confirmez-vous votre disponibilité pour cette mission ?',
      confirmLabel: 'Accepter',
    );

    if (!confirmed || !mounted) return;

    await _runAction(
      () => _service.acceptMission(widget.mission.id),
      successMessage: 'Mission acceptée.',
    );
  }

  Future<void> _decline() async {
    _commentController.clear();
    _declineReason = 'UNAVAILABLE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Décliner la proposition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pourquoi déclinez-vous cette mission ?'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _declineReason,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Motif',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'UNAVAILABLE',
                      child: Text('Indisponible'),
                    ),
                    DropdownMenuItem(
                      value: 'SCHEDULE_CONFLICT',
                      child: Text('Conflit d’horaires'),
                    ),
                    DropdownMenuItem(
                      value: 'OTHER',
                      child: Text('Autre motif'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        _declineReason = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (facultatif)',
                    hintText: 'Précisez votre motif...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Retour'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Décliner'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    await _runAction(
      () => _service.declineMission(
        reference: widget.mission.id,
        reason: _declineReason,
        comment: _commentController.text,
      ),
      successMessage: 'Proposition déclinée.',
    );
  }

  Future<void> _cancel() async {
    // Vérification locale avant la confirmation.
    if (!_canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L’annulation est possible uniquement plus de 24 h avant le début.',
          ),
        ),
      );
      return;
    }

    final confirmed = await _confirm(
      title: 'Annuler cette mission ?',
      message: 'Cette action annulera votre mission. Voulez-vous continuer ?',
      confirmLabel: 'Annuler la mission',
    );

    if (!confirmed || !mounted) return;

    await _runAction(
      () => _service.cancelMission(widget.mission.id),
      successMessage: 'Mission annulée.',
    );
  }

  Future<void> _start() async {
    final confirmed = await _confirm(
      title: 'Démarrer la mission ?',
      message: 'Confirmez-vous le début de votre intervention ?',
      confirmLabel: 'Démarrer',
    );

    if (!confirmed || !mounted) return;

    await _runAction(
      () => _service.startMission(widget.mission.id),
      successMessage: 'Mission démarrée.',
    );
  }

  Future<void> _submitHours() async {
    final hours = double.tryParse(
      _hoursController.text.trim().replaceAll(',', '.'),
    );

    if (hours == null || hours <= 0 || hours > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saisissez un nombre d’heures valide, entre 0 et 24.'),
        ),
      );
      return;
    }

    final confirmed = await _confirm(
      title: 'Confirmer les heures',
      message: 'Enregistrer $hours heure(s) effectuée(s) ?',
      confirmLabel: 'Enregistrer',
    );

    if (!confirmed || !mounted) return;

    await _runAction(
      () => _service.submitMissionHours(
        reference: widget.mission.id,
        actualHours: hours,
      ),
      successMessage: 'Heures enregistrées.',
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    Color? background,
    Color foreground = Colors.white,
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: background ?? AppColors.navy,
        foregroundColor: foreground,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }

  Widget _buildActions() {
    if (_isProposed) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Décliner',
              icon: Icons.close,
              outlined: true,
              onPressed: _decline,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              label: 'Accepter',
              icon: Icons.check,
              background: AppColors.navy,
              onPressed: _accept,
            ),
          ),
        ],
      );
    }

    if (_isAccepted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionButton(
            label: 'Démarrer la mission',
            icon: Icons.play_arrow,
            onPressed: _start,
          ),
          if (_canCancel) ...[
            const SizedBox(height: 10),
            _actionButton(
              label: 'Annuler la mission',
              icon: Icons.event_busy_outlined,
              outlined: true,
              onPressed: _cancel,
            ),
          ],
          if (!_canCancel) ...[
            const SizedBox(height: 8),
            const Text(
              'L’annulation n’est plus disponible à moins de 24 h du début.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      );
    }

    if (_isStarted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Heures réellement effectuées',
              hintText: 'Ex. 8',
              suffixText: 'heures',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _actionButton(
            label: 'Enregistrer les heures',
            icon: Icons.save_outlined,
            onPressed: _submitHours,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;

    final statusLabel = _isStarted
        ? 'Mission en cours'
        : _isAccepted
        ? 'Mission acceptée'
        : _isProposed
        ? 'Nouvelle proposition'
        : _isCompleted
        ? 'Mission terminée'
        : 'Détail de la mission';

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E5EC),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mission.status,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    mission.clientShort.isNotEmpty ? mission.clientShort : 'AY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.role,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.client,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            Icons.calendar_month_outlined,
                            'Date',
                            _formatDate(mission.date),
                            iconBackground: const Color(0xFFFFEAC7),
                            iconColor: AppColors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoTile(
                            Icons.access_time,
                            'Horaires',
                            '${mission.start} — ${mission.end}',
                            iconBackground: const Color(0xFFDCE7FF),
                            iconColor: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            Icons.work_outline,
                            'Durée prévue',
                            '${mission.duration} heures',
                            iconBackground: const Color(0xFFDCE7FF),
                            iconColor: AppColors.navy,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoTile(
                            Icons.location_on_outlined,
                            'Adresse',
                            mission.address.isEmpty
                                ? 'Non renseignée'
                                : mission.address,
                            iconBackground: const Color(0xFFFFEAC7),
                            iconColor: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.navy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mission.instructions?.trim().isNotEmpty ==
                                          true
                                      ? mission.instructions!
                                      : _isStarted
                                      ? 'Renseignez les heures réellement effectuées après votre intervention.'
                                      : _isAccepted
                                      ? 'Votre mission est confirmée. Consultez les horaires et l’adresse avant votre intervention.'
                                      : _isProposed
                                      ? 'Consultez les informations de cette mission avant de répondre à la proposition.'
                                      : 'Consultez les informations de votre mission.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    else
                      _buildActions(),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
