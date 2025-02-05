import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/user_model.dart';

class DatabaseHelper{
  static final DatabaseHelper _intance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        userid TEXT PRIMARY KEY,
        nome TEXT,
        email TEXT,
        senha TEXT,
        telefone TEXT,
        tipoDeUsuario TEXT,
        especializacao TEXT,
        dataCadastro TEXT,
        localizacao TEXT
      )    
    ''');

    await db.execute('''
      CREATE TABLE trabalhos(
        jobId TEXT PRIMARY KEY,
        titulo TEXT,
        descricao TEXT,
        categoria TEXT,
        orcamento TEXT,
        dataCriacao TEXT,
        dataLimite TEXT,
        cidadaoId TEXT,
        prazo TEXT,
        status TEXT,
        localizacao TEXT
      )
    ''');

    await db.execute
    ('''
      CREATE TABLE propostas(
        proposalId TEXT PRIMARY KEY,
        valor REAl,
        descricao TEXT,
        dataProposta TEXT,
        status TEXT,
        

      )
    ''')
  }

}