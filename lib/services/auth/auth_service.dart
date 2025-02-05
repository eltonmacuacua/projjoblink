import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/user_model.dart';
import '../../utils/database_helper.dart';

class AuthService{
  final DatabaseHelper _dbHelper = DatabaseHelper.intance;

  String _hashPasword(String password) {
    var bytes = utf8.encode(password);
    var digits = sha256.convert(bytes);
    return digits.toString();
  }

  Future<bool> registerUser(Usuario user) async{
    try{
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> existingUsers = await db.query(
        'usuarios', 
        where: 'email = ?', 
        whereArgs: [user.email],
      );

      if(existingUsers.isNotEmpty){
        return false;
      }

      final userMap = user.toMap();
      userMap['senha'] = _hashPassword(user.senha);

      await db.insert('usuarios', userMap);
      return true
    } catch(e){
      print('Erro de cadastro: $e');
      return false;
    }
  }


  Future<Usuario?> login(String email, String password) async{
    try{
      final db = await _dbHelper.database;
      final hashedPassword = _hashPassword(password);
      final List<Map<String, dynamic>> results = await db.query(
        'usuarios',
        where: 'email = ? AND senha = ?',
        whereArgs: [email, hashedPassword],
      );

      if (results.isEmpty)  return null;

      await _saveSession(results.first['userid']);
      return Usuario.fromMap(results.first);
    } catch (e){
      print('Erro ao iniciar sessao');
      return null;
    }
  }


  Future<void> _saveSession(String userid) async{
    final prefs = await shared_preferences.getInstance();
    await prefs.setString('userid', userid);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<bool> isLoggedIn() async{
    final prefs = await shared_preferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

}