
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;
  final dynamic phone;
  final Map<String, dynamic>? employeeProfile;
  final Map<String, dynamic>? clientOrganization;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.employeeProfile,
    this.clientOrganization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone'],
      employeeProfile: json['employeeProfile'] is Map
          ? Map<String, dynamic>.from(json['employeeProfile'])
          : null,
      clientOrganization: json['clientOrganization'] is Map
          ? Map<String, dynamic>.from(json['clientOrganization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'employeeProfile': employeeProfile,
      'clientOrganization': clientOrganization,
    };
  }
}
