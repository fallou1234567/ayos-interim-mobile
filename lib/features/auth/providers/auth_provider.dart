
import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_service.dart';
import '../models/user_model.dart';
import '../services/notice_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _legalStatus;
  bool _isLegalStatusLoading = false;
  bool _isLegalStatusChecked = false;

  // =========================
  // AUTHENTIFICATION
  // =========================

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  String? get errorMessage => _errorMessage;

  // =========================
  // STATUT JURIDIQUE
  // =========================

  Map<String, dynamic>? get legalStatus => _legalStatus;

  bool get isLegalStatusLoading => _isLegalStatusLoading;

  bool get isLegalStatusChecked => _isLegalStatusChecked;

  /// Les CGU nécessitent-elles une acceptation ?
  bool get requiresTermsAcceptance {
    if (!_isLegalStatusChecked || _legalStatus == null) {
      return true;
    }

    return _legalStatus!['enforced'] == true &&
        (_legalStatus!['acceptanceRequired'] == true ||
            _legalStatus!['termsAcceptanceRequired'] == true);
  }

  /// La notice salarié doit-elle être présentée ?
  bool get requiresNoticePresentation {
    if (!_isLegalStatusChecked || _legalStatus == null) {
      return false;
    }

    return _legalStatus!['enforced'] == true &&
        _legalStatus!['noticePresentationRequired'] == true;
  }

  /// Une action juridique est-elle nécessaire ?
  bool get requiresLegalAction =>
      requiresTermsAcceptance || requiresNoticePresentation;

  // =========================
  // CONNEXION
  // =========================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // RESTAURATION DE SESSION
  // =========================

  Future<void> restoreSession() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();

      // Vérifier les obligations juridiques après restauration.
      await refreshLegalStatus();
    } catch (_) {
      await TokenStorage.clear();

      _user = null;
      _legalStatus = null;
      _isLegalStatusChecked = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // MISE À JOUR DU PROFIL
  // =========================

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.updateProfile(
        name: name,
        phone: phone,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // VÉRIFICATION DU STATUT JURIDIQUE
  // =========================

  Future<bool> refreshLegalStatus() async {
    _isLegalStatusLoading = true;
    _isLegalStatusChecked = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _legalStatus = await NoticeService.getLegalStatus();

      _isLegalStatusChecked = true;

      return true;
    } catch (e) {
      _legalStatus = null;
      _isLegalStatusChecked = false;

      _errorMessage =
          'Impossible de vérifier les obligations juridiques.';

      debugPrint('Erreur statut juridique : $e');

      return false;
    } finally {
      _isLegalStatusLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // DÉCONNEXION
  // =========================

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (_) {
      await TokenStorage.clear();
    } finally {
      _user = null;
      _legalStatus = null;
      _isLegalStatusChecked = false;
      _isLegalStatusLoading = false;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    }
  }
}
