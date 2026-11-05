import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/legal_document_model.dart';
import '../services/notice_service.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  List<LegalDocumentModel> _documents = [];

  LegalDocumentModel? _employeeNotice;
  LegalDocumentModel? _terms;

  bool _requiresNotice = false;
  bool _requiresTerms = false;

  bool _noticeRead = false;
  bool _termsAccepted = false;
  bool _loading = true;
  bool _submitting = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final authProvider = context.read<AuthProvider>();

      if (!authProvider.isLegalStatusChecked) {
        throw Exception('Statut juridique non vérifié.');
      }

      final requiresNotice = authProvider.requiresNoticePresentation;

      final requiresTerms = authProvider.requiresTermsAcceptance;

      final documents = await NoticeService.getLegalDocuments();

      final notice = documents.where((d) => d.isEmployeeNotice).firstOrNull;

      final terms = documents.where((d) => d.isTerms).firstOrNull;

      if (requiresNotice && notice == null) {
        throw Exception('La notice salarié est introuvable.');
      }

      if (requiresTerms && terms == null) {
        throw Exception('Les conditions générales sont introuvables.');
      }

      if (!mounted) return;

      setState(() {
        _documents = documents;
        _employeeNotice = notice;
        _terms = terms;

        _requiresNotice = requiresNotice;
        _requiresTerms = requiresTerms;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Impossible de récupérer les documents juridiques. '
            'Vérifiez votre connexion.';
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_requiresNotice && !_noticeRead) return;
    if (_requiresTerms && !_termsAccepted) return;

    if (_requiresNotice && _employeeNotice == null) return;
    if (_requiresTerms && _terms == null) return;

    setState(() => _submitting = true);

    try {
      // 1. Enregistrer la prise de connaissance de la notice salarié.
      if (_requiresNotice) {
        await NoticeService.acknowledgeNotice(_employeeNotice!.id);
      }

      // 2. Enregistrer l'acceptation des CGU.
      if (_requiresTerms) {
        await NoticeService.acceptTerms(_terms!.id);
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’enregistrer vos informations juridiques : $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _openDocument(LegalDocumentModel document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Version ${document.version}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: SelectableText(
                        document.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _documentTile(LegalDocumentModel document) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        tileColor: AppColors.white,
        splashColor: AppColors.navy.withValues(alpha: 0.08),
        leading: const Icon(Icons.description_outlined, color: AppColors.navy),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Version ${document.version}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openDocument(document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Informations légales',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.navy,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadDocuments();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final otherDocuments = _documents
        .where((document) => document.id != _employeeNotice?.id)
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 42,
                color: AppColors.navy,
              ),

              const SizedBox(height: 12),

              if (_requiresNotice && _employeeNotice != null) ...[
                Text(
                  _employeeNotice!.title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Version ${_employeeNotice!.version}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                SelectableText(
                  _employeeNotice!.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 12),
              ],

              const Text(
                'Autres documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              ...otherDocuments.map(_documentTile),
            ],
          ),
        ),

        _buildAcceptancePanel(),
      ],
    );
  }

  Widget _buildAcceptancePanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          if (_requiresNotice)
            CheckboxListTile(
              value: _noticeRead,
              onChanged: (value) {
                setState(() {
                  _noticeRead = value ?? false;
                });
              },
              activeColor: AppColors.navy,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Je confirme avoir pris connaissance de la notice '
                'd’information des salariés.',
                style: TextStyle(fontSize: 13),
              ),
            ),

          if (_requiresTerms)
            CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
              activeColor: AppColors.navy,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'J’accepte les conditions générales d’utilisation (CGU).',
                style: TextStyle(fontSize: 13),
              ),
            ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  !_submitting &&
                      (!_requiresNotice || _noticeRead) &&
                      (!_requiresTerms || _termsAccepted)
                  ? _submit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}
