class LegalDocumentModel {
  final String id;
  final String kind;
  final String version;
  final String title;
  final String content;
  final bool pdfAvailable;
  final List<String> roles;

  const LegalDocumentModel({
    required this.id,
    required this.kind,
    required this.version,
    required this.title,
    required this.content,
    required this.pdfAvailable,
    required this.roles,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      pdfAvailable: json['pdfAvailable'] == true,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
    );
  }

  bool get isTerms => kind == 'TERMS';
  bool get isEmployeeNotice => kind == 'EMPLOYEE_NOTICE';
}