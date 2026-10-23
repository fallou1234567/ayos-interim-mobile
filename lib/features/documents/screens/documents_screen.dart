import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_page_header.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final Dio _dio = ApiClient.instance.dio;

  static const int _maxFileSize = 10 * 1024 * 1024;

  final List<_DocumentType> _documentTypes = const [
    _DocumentType(
      category: 'IDENTITY',
      title: "Pièce d'identité",
      icon: Icons.badge_outlined,
    ),
    _DocumentType(
      category: 'HEALTH_CARD',
      title: 'Carte de santé',
      icon: Icons.health_and_safety_outlined,
    ),
    _DocumentType(
      category: 'BANK_DETAILS',
      title: 'RIB / Coordonnées bancaires',
      icon: Icons.account_balance_outlined,
    ),
    _DocumentType(
      category: 'RESIDENCE_PERMIT',
      title: 'Titre de séjour',
      icon: Icons.credit_card_outlined,
    ),
  ];

  List<_Document> _documents = [];
  bool _isLoading = true;
  bool _isPicking = false;
  String? _errorMessage;
  String? _uploadingCategory;

  int get _providedCount => _documentTypes.where((type) {
    return _documents.any((document) => document.category == type.category);
  }).length;

  int get _verifiedCount => _documentTypes.where((type) {
    return _documents.any(
      (document) =>
          document.category == type.category && _isApproved(document.status),
    );
  }).length;

  double get _progress =>
      _documentTypes.isEmpty ? 0 : _verifiedCount / _documentTypes.length;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  bool _isApproved(String status) {
    return const {
      'APPROVED',
      'VALIDATED',
      'VERIFIED',
    }.contains(status.toUpperCase());
  }

  bool _isRejected(String status) {
    return const {'REJECTED', 'REFUSED'}.contains(status.toUpperCase());
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente de vérification';
      case 'APPROVED':
      case 'VALIDATED':
      case 'VERIFIED':
        return 'Validé';
      case 'REJECTED':
      case 'REFUSED':
        return 'Refusé';
      default:
        return status.isEmpty ? 'Statut inconnu' : status;
    }
  }

  Color _statusColor(String status) {
    if (_isApproved(status)) return AppColors.green;
    if (_isRejected(status)) return Colors.red;
    if (status.toUpperCase() == 'PENDING') return AppColors.orange;
    return AppColors.textSecondary;
  }


  _Document? _latestDocumentFor(String category) {
    final matches = _documents
        .where((document) => document.category == category)
        .toList();

    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      final aDate = a.uploadedAt ?? DateTime(1970);
      final bDate = b.uploadedAt ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

    return matches.first;
  }

  Future<void> _loadDocuments({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _dio.get('/employees/me/documents');

      final dynamic responseData = response.data;
      final dynamic rawDocuments =
          responseData is Map && responseData['data'] is List
          ? responseData['data']
          : responseData;

      if (rawDocuments is! List) {
        throw Exception(
          'Le format des documents retourné par le serveur est invalide.',
        );
      }

      final documents = rawDocuments.map((item) {
        return _Document.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();

      if (!mounted) return;

      setState(() {
        _documents = documents;
        _errorMessage = null;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _apiErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Impossible de charger les documents.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _apiErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return 'Votre session a expiré ou vous n’avez pas accès à ces documents. '
          'Veuillez vous reconnecter si nécessaire.';
    }

    if (statusCode == 413) {
      return 'Le fichier envoyé est trop volumineux.';
    }

    if (statusCode == 422) {
      return 'Le fichier ou la catégorie est refusé par le serveur. '
          'Vérifiez le document et réessayez.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Le serveur met trop de temps à répondre. Réessayez.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Connexion impossible. Vérifiez votre connexion Internet.';
    }

    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    return 'Une erreur est survenue lors du chargement des documents.';
  }

  Future<void> _pickAndUploadDocument(_DocumentType type) async {
    if (_isPicking || _uploadingCategory != null) return;

    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: false,
      );

      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;

      if (file.size > _maxFileSize) {
        _showMessage(
          'Le fichier dépasse la limite autorisée de 10 Mo.',
          isError: true,
        );
        return;
      }

      final path = file.path;
      if (path == null || path.isEmpty) {
        _showMessage(
          'Impossible d’accéder au fichier sélectionné sur cet appareil.',
          isError: true,
        );
        return;
      }

      setState(() {
        _isPicking = false;
        _uploadingCategory = type.category;
      });

      final formData = FormData.fromMap({
        'category': type.category,
        'file': await MultipartFile.fromFile(path, filename: file.name),
      });

      await _dio.post('/employees/me/documents', data: formData);

      if (!mounted) return;

      _showMessage('${type.title} envoyé avec succès.');

      await _loadDocuments(showLoader: false);
    } on DioException catch (e) {
      if (!mounted) return;

      _showMessage(_apiErrorMessage(e), isError: true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Impossible d’envoyer le document. Veuillez réessayer.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
          _uploadingCategory = null;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : AppColors.navy,
        ),
      );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date indisponible';

    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');

    return '$day/$month/${d.year}';
  }

  void _showDocumentDetails(_DocumentType type) {
    final document = _latestDocumentFor(type.category);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  document?.fileName ?? 'Aucun document envoyé',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (document != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Statut : ${_statusLabel(document.status)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(document.status),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Envoyé le ${_formatDate(document.uploadedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (document.reviewNote != null &&
                      document.reviewNote!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Commentaire de vérification',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      document.reviewNote!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPicking || _uploadingCategory != null
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _pickAndUploadDocument(type);
                          },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      document == null
                          ? 'Choisir et envoyer'
                          : 'Envoyer un nouveau fichier',
                    ),
                  ),
                ),
                if (document != null && _isRejected(document.status)) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Ce document a été refusé. Consultez le commentaire '
                    'de vérification avant de le renvoyer.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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
          onRefresh: () => _loadDocuments(showLoader: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
             AppPageHeader(
  sectionLabel: 'Dossier administratif',
  title: 'Mes documents',
  description:
      'Envoyez vos pièces administratives à AYOS et suivez leur statut de vérification.',
),
const SizedBox(height: 0),
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
              // const SizedBox(height: 8),
              // const Text(
              //   'Mes documents',
              //   style: TextStyle(
              //     fontSize: 21,
              //     fontWeight: FontWeight.w400,
              //     color: AppColors.textPrimary,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // const Text(
              //   'Envoyez vos pièces administratives à AYOS et '
              //   'suivez leur statut de vérification.',
              //   style: TextStyle(
              //     fontSize: 10,
              //     height: 1.5,
              //     color: AppColors.textSecondary,
              //   ),
              // ),
              // const SizedBox(height: 18),
              const SizedBox(height: 18),
              if (_isLoading && _documents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (_errorMessage != null) ...[
                  _errorCard(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _loadDocuments(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                      '$_providedCount/${_documentTypes.length} envoyées',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(_documentTypes.length, (index) {
                  final type = _documentTypes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _documentCard(type),
                  );
                }),
                const SizedBox(height: 12),
                _confidentialityCard(),
                if (_uploadingCategory != null) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Envoi du document en cours…',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCCCC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _errorMessage ?? 'Une erreur est survenue.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
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
                      'sur ${_documentTypes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_providedCount pièce(s) envoyée(s). '
                      'Suivez leur vérification par AYOS.',
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

  Widget _documentCard(_DocumentType type) {
    final document = _latestDocumentFor(type.category);
    final isUploading = _uploadingCategory == type.category;

    final status = document == null
        ? 'Non fourni'
        : _statusLabel(document.status);

    final statusColor = document == null
        ? AppColors.textSecondary
        : _statusColor(document.status);

    final isRejected = document != null && _isRejected(document.status);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showDocumentDetails(type),
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
                  color: isRejected
                      ? const Color(0xFFFFE8E8)
                      : document == null
                      ? AppColors.lightBlue
                      : const Color(0xFFFFF2DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  type.icon,
                  size: 18,
                  color: isRejected
                      ? Colors.red
                      : document == null
                      ? AppColors.navy
                      : statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document?.fileName ?? 'Aucun fichier envoyé',
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
                    if (document != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Envoyé le ${_formatDate(document.uploadedAt)}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (isUploading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  document == null
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
                  'Vos documents sont transmis à AYOS par une connexion '
                  'sécurisée. Ne partagez pas vos pièces administratives '
                  'avec des personnes non autorisées.',
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

class _DocumentType {
  const _DocumentType({
    required this.category,
    required this.title,
    required this.icon,
  });

  final String category;
  final String title;
  final IconData icon;
}

class _Document {
  const _Document({
    required this.id,
    required this.category,
    required this.fileName,
    required this.mimeType,
    required this.status,
    this.reviewNote,
    this.uploadedAt,
    this.reviewedAt,
  });

  final String id;
  final String category;
  final String fileName;
  final String mimeType;
  final String status;
  final String? reviewNote;
  final DateTime? uploadedAt;
  final DateTime? reviewedAt;

  factory _Document.fromJson(Map<String, dynamic> json) {
    return _Document(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? 'Document',
      mimeType: json['mimeType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      reviewNote: json['reviewNote']?.toString(),
      uploadedAt: DateTime.tryParse(json['uploadedAt']?.toString() ?? ''),
      reviewedAt: DateTime.tryParse(json['reviewedAt']?.toString() ?? ''),
    );
  }
}
