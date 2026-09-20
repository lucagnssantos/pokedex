import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o estado de sessão do usuário (RF07 — login local baseline).
/// Não é autenticação real contra servidor: guarda um usuário/senha
/// simples no dispositivo, só para exigir login antes do catálogo.
class AuthProvider extends ChangeNotifier {
  static const _keyRegisteredUser = 'auth_registered_user';
  static const _keyRegisteredPass = 'auth_registered_pass';
  static const _keyLoggedIn = 'auth_logged_in';

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUser;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  /// Verifica ao abrir o app se já existe uma sessão salva.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _currentUser = prefs.getString(_keyRegisteredUser);
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Preencha usuário e senha.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegisteredUser, username.trim());
    await prefs.setString(_keyRegisteredPass, password);
    await prefs.setBool(_keyLoggedIn, true);

    _currentUser = username.trim();
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString(_keyRegisteredUser);
    final savedPass = prefs.getString(_keyRegisteredPass);

    // Pequeno atraso simulando uma chamada, para exercitar o
    // CircularProgressIndicator (RF09) também no login.
    await Future.delayed(const Duration(milliseconds: 400));

    if (savedUser == username.trim() && savedPass == password) {
      await prefs.setBool(_keyLoggedIn, true);
      _currentUser = savedUser;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Usuário ou senha inválidos.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    _isLoggedIn = false;
    notifyListeners();
  }
}
