import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB('joblink.db');
      return _database!;
    } catch(e){
      print('Erro ao inicializar o banco de dados: $e');
      throw Exception('Erro ao inicializar o banco de dados');
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path, 
        version: 1, 
        onCreate: _onCreate, 
        onOpen: (db) async {
          print('Banco de dados aberto com sucesso!');
        },
      );
    } catch(e){
      print('Erro ao inicializar o banco de dados: $e');
      throw Exception('Erro ao inicializar o banco de dados');
    }
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
        localizacao TEXT,
        FOREIGN KEY (cidadaoId) REFERENCES usarios (userid)
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
        cidadao TEXT,
        freelancerId TEXT,
        FOREIGN KEY (cidadaoId) REFERENCES usarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usarios (userid)
      )
    ''');

    await db.execute(
      '''
      CREATE TABLE avaliacoes (
        reviewId TEXT PRIMARY KEY,
        cidadaoId TEXT,
        freelancerId TEXT,
        trabalhoId TEXT,
        comentario TEXT,
        nota TEXT,
        dataCriacao TEXT,
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usuarios (userid),
        FOREIGN KEY (trabalhoId) REFERENCES trabalhos (jobId)
      )
      '''
    );

    await db.execute(
      '''
      CREATE TABLE mensangens(
        mensagemId TEXT PRIMARY KEY,
        conteudo TEXT,
        dataEnvio TEXT,
        lida TEXT,
        cidadaoId TEXT,
        freelancerId TEXT, 
        FOREIGN KEY (cidadaoId) REFERENCES usuarios (userid),
        FOREIGN KEY (freelancerId) REFERENCES usuarios (userid)
      )
      '''
    );
  }

}