// lib/services/auth/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/user.dart';
import '../database/sqlite_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // Método para hash da senha
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Método para cadastro de usuário
  Future<bool> registerUser(Usuario user) async {
    try {
      final db = await _dbHelper.database;
      
      final List<Map<String, dynamic>> existingUsers = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [user.email],
      );

      if (existingUsers.isNotEmpty) {
        return false;
      }

      final userMap = user.toMap();
      userMap['senha'] = _hashPassword(user.senha);
      
      await db.insert('usuarios', userMap);
      return true;
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  // Método para login
  Future<Usuario?> login(String email, String password) async {
  try {
    final db = await _dbHelper.database;
    final hashedPassword = _hashPassword(password);
    final List<Map<String, dynamic>> results = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, hashedPassword],
    );
    
    if (results.isEmpty) return null;
    
    await _saveSession(results.first['userid']);
    return Usuario.fromMap(results.first);
  } catch (e) {
    print('Erro no login: $e');
    return null;
  }
}

  // Salvar sessão do usuário
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setBool('isLoggedIn', true);
  }

  // Verificar se usuário está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}