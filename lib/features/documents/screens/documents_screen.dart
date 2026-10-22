import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<_LocalDocument> _documents = [
    _LocalDocument(title: "Pièce d'identité", icon: Icons.badge_outlined),
    _LocalDocument(
      title: 'Carte Vitale',
      icon: Icons.health_and_safety_outlined,
    ),
    _LocalDocument(title: 'RIB', icon: Icons.account_balance_outlined),
    _LocalDocument(title: 'Titre de séjour', icon: Icons.credit_card_outlined),
  ];

  bool _isPicking = false;

  int get _providedCount =>
      _documents.where((doc) => doc.fileName != null).length;

  int get _verifiedCount => _documents.where((doc) => doc.verified).length;

  double get _progress =>
      _documents.isEmpty ? 0 : _verifiedCount / _documents.length;

  Future<void> _pickDocument(int index) async {
    if (_isPicking) return;

    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;

      setState(() {
        _documents[index]
          ..fileName = file.name
          ..filePath = file.path
          ..verified = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${file.name} ajouté localement. '
            'Il reste à transmettre et à faire vérifier.',
          ),
          backgroundColor: AppColors.navy,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de sélectionner ce fichier.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _showDocumentDetails(int index) {
    final document = _documents[index];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  document.fileName ?? 'Aucun fichier sélectionné',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le fichier reste sur cet appareil. '
                  'Il n’a pas été envoyé à AYOS.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPicking
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _pickDocument(index);
                          },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      document.fileName == null
                          ? 'Choisir un fichier'
                          : 'Remplacer le fichier',
                    ),
                  ),
                ),
                if (document.fileName != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          document
                            ..fileName = null
                            ..filePath = null
                            ..verified = false;
                        });
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Retirer le fichier'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Aucun appel réseau dans cette version locale.
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              _header(),
              const SizedBox(height: 25),
              const Text(
                'DOSSIER ADMINISTRATIF',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mes documents',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez vos pièces administratives. '
                'Vous pourrez les transmettre à AYOS lorsque '
                'la connexion au serveur sera disponible.',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _verificationCard(),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mes pièces',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$_providedCount/${_documents.length} ajoutés',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(_documents.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _documentCard(index),
                );
              }),
              const SizedBox(height: 12),
              _confidentialityCard(),
              if (_isPicking) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo2.png',
          width: 70,
          errorBuilder: (_, _, _) => const Icon(
            Icons.description_outlined,
            size: 35,
            color: AppColors.navy,
          ),
        ),
        const Spacer(),
        _headerIcon(Icons.wb_sunny_outlined),
        const SizedBox(width: 8),
        _headerIcon(Icons.notifications_none),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.navy,
          child: Text(
            'AY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.orange,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_verifiedCount document'
                      '${_verifiedCount > 1 ? 's' : ''} vérifié'
                      '${_verifiedCount > 1 ? 's' : ''} '
                      'sur ${_documents.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _verifiedCount == _documents.length
                          ? 'Toutes les pièces sont vérifiées.'
                          : '$_providedCount pièce(s) sélectionnée(s). '
                                'Vérification à effectuer par AYOS.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${(_progress * 100).round()} % vérifié',
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(int index) {
    final document = _documents[index];

    final String status;
    final Color statusColor;
    final bool warning;

    if (document.verified) {
      status = 'Vérifié';
      statusColor = AppColors.green;
      warning = false;
    } else if (document.fileName != null) {
      status = 'À transmettre';
      statusColor = AppColors.orange;
      warning = true;
    } else {
      status = 'Non fourni';
      statusColor = AppColors.textSecondary;
      warning = false;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showDocumentDetails(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: warning
                      ? const Color(0xFFFFF2DC)
                      : AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  document.icon,
                  size: 18,
                  color: warning ? AppColors.orange : AppColors.navy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.fileName ?? 'Aucun fichier sélectionné',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                document.fileName == null
                    ? Icons.add_circle_outline
                    : Icons.chevron_right,
                size: 19,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confidentialityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4DDB5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: AppColors.orange),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données restent confidentielles',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Les fichiers sélectionnés ne sont pas envoyés '
                  'au serveur dans cette version. La transmission '
                  'sécurisée sera ajoutée lors de la connexion à l’API.',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 17, color: AppColors.textSecondary),
    );
  }
}

class _LocalDocument {
  _LocalDocument({required this.title, required this.icon});

  final String title;
  final IconData icon;

  String? fileName;
  String? filePath;
  bool verified = false;
}
