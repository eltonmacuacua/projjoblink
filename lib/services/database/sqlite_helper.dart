// lib/services/database/sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/job.dart';
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDB('joblink.db');
      return _database!;
    } catch (e) {
      print('Erro ao inicializar banco de dados: $e');
      throw Exception('Falha ao inicializar banco de dados');
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) async {
          print('Banco de dados aberto com sucesso');
        },
      );
    } catch (e) {
      print('Erro ao inicializar DB: $e');
      throw Exception('Falha ao inicializar banco de dados');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Criação da tabela de usuários
    await db.execute('''
      CREATE TABLE usuarios (
        userid TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        telefone TEXT,
        tipoDeUsuario TEXT NOT NULL,
        especializacao TEXT,
        dataCadastro TEXT NOT NULL,
        localizacao TEXT
      )
    ''');

    // Criação da tabela de trabalhos
    await db.execute('''
      CREATE TABLE trabalhos (
        jobId TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        orcamento TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        dataLimite TEXT NOT NULL,
        cidadaoId TEXT NOT NULL,
        prazo TEXT NOT NULL,
        status TEXT NOT NULL,
        localizacao TEXT,
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid)
      )
    ''');

    // Criação da tabela de propostas
    await db.execute('''
      CREATE TABLE propostas (
        proposalId TEXT PRIMARY KEY,
        valor TEXT NOT NULL,
        descricao TEXT NOT NULL,
        dataProposta TEXT NOT NULL,
        status TEXT NOT NULL,
        cidadaoId TEXT NOT NULL,
        freelancerId TEXT NOT NULL,
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usuarios (userid)
      )
    ''');

    // Criação da tabela de avaliações
    await db.execute('''
      CREATE TABLE avaliacoes (
        reviewId TEXT PRIMARY KEY,
        cidadaoId TEXT NOT NULL,
        freelancerId TEXT NOT NULL,
        trabalhoId TEXT NOT NULL,
        comentario TEXT NOT NULL,
        nota TEXT NOT NULL,
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usuarios (userid),
        FOREIGN KEY (trabalhoId) REFERENCES trabalhos (jobId)
      )
    ''');
    
    // Criação da tabela de mensagens
    await db.execute('''
      CREATE TABLE mensagens (
        mensagemId TEXT PRIMARY KEY,
        conteudo TEXT NOT NULL,
        dataEnvio TEXT NOT NULL,
        lida TEXT NOT NULL,
        cidadaoId TEXT NOT NULL,
        freelancerId TEXT NOT NULL,
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usuarios (userid)
      )
    ''');
  }

  
}

//codigo para criar trabalhos
extension JobOperations on DatabaseHelper {
  Future<String> insertTrabalho(Trabalho trabalho) async {
    try {
      final db = await database;
      await db.insert(
        'trabalhos', 
        trabalho.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return trabalho.jobId;
    } catch (e) {
      print('Erro ao inserir trabalho: $e');
      throw Exception('Falha ao criar trabalho');
    }
  }

  Future<List<Trabalho>> getTrabalhosByCidadao(String cidadaoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trabalhos',
      where: 'cidadaoId = ?',
      whereArgs: [cidadaoId],
    );
    return maps.map((map) => Trabalho.fromMap(map)).toList();
  }
}