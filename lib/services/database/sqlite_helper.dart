// lib/services/database/sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/job.dart';
import '../../models/proposal.dart';
import '../../models/user.dart';

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

  Future<List<Usuario>> getProfessionalUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'tipoDeUsuario = ?',
      whereArgs: ['freelancer'],
    );

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    final db = await database;
    return await db.query(
      'mensagens',
      where: 'cidadaoId = ?',
      whereArgs: [userId],
      orderBy: 'dataEnvio DESC',
    );
  }

  Future<void> markMessageAsRead(String messageId) async {
    final db = await database;
    await db.update(
      'mensagens',
      {'lida': 'true'},
      where: 'mensagemId = ?',
      whereArgs: [messageId],
    );
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

  Future<void> deleteTrabalho(String jobId) async {
    try {
      final db = await database;
      await db.delete(
        'trabalhos',
        where: 'jobId = ?',
        whereArgs: [jobId],
      );
    } catch (e) {
      print('Erro ao deletar trabalho: $e');
      throw Exception('Falha ao deletar trabalho');
    }
  }

  Future<void> updateTrabalho(Trabalho trabalho) async {
    try {
      final db = await database;
      await db.update(
        'trabalhos',
        trabalho.toMap(),
        where: 'jobId = ?',
        whereArgs: [trabalho.jobId],
      );
    } catch (e) {
      print('Erro ao atualizar trabalho: $e');
      throw Exception('Falha ao atualizar trabalho');
    }
  }

  Future<List<Proposta>> getPropostasByTrabalho(String jobId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*, u.nome as freelancerNome
        FROM propostas p
        JOIN usuarios u ON p.freelancerId = u.userid
        WHERE p.cidadaoId = ?
      ''', [jobId]);

      return maps.map((map) => Proposta.fromMap(map)).toList();
    } catch (e) {
      print('Erro ao buscar propostas: $e');
      throw Exception('Falha ao buscar propostas');
    }
  }
}

//codigo para criar clientes
extension UserOperations on DatabaseHelper {
  Future<void> updateUsuario(Usuario usuario) async {
    try {
      final db = await database;
      await db.update(
        'usuarios',
        usuario.toMap(),
        where: 'userid = ?',
        whereArgs: [usuario.userid],
      );
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw Exception('Falha ao atualizar usuário');
    }
  }

  Future<void> deleteUsuario(String userId) async {
    try {
      final db = await database;
      await db.delete(
        'usuarios',
        where: 'userid = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      throw Exception('Falha ao deletar usuário');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final db = await database;

      // Total de trabalhos
      final totalTrabalhos = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM trabalhos WHERE cidadaoId = ?',
            [userId],
          )) ??
          0;

      // Trabalhos por status
      final trabalhosPendentes = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM trabalhos WHERE cidadaoId = ? AND status = 'Em Andamento'",
            [userId],
          )) ??
          0;

      final trabalhosAbertos = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM trabalhos WHERE cidadaoId = ? AND status = 'Aberto'",
            [userId],
          )) ??
          0;

      final trabalhosConcluidos = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM trabalhos WHERE cidadaoId = ? AND status = 'Concluído'",
            [userId],
          )) ??
          0;

      // Média de avaliações
      final mediaAvaliacoes = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT AVG(CAST(nota AS FLOAT)) FROM avaliacoes WHERE cidadaoId = ?',
            [userId],
          )) ??
          0;

      // Total de propostas recebidas
      final totalPropostas = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM propostas WHERE cidadaoId = ?',
            [userId],
          )) ??
          0;

      return {
        'totalTrabalhos': totalTrabalhos,
        'trabalhosPendentes': trabalhosPendentes,
        'trabalhosAbertos': trabalhosAbertos,
        'trabalhosConcluidos': trabalhosConcluidos,
        'mediaAvaliacoes': mediaAvaliacoes,
        'totalPropostas': totalPropostas,
      };
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      throw Exception('Falha ao buscar estatísticas do usuário');
    }
  }
}

extension AuthOperations on DatabaseHelper {
  Future<void> logout(String userId) async {
    try {
      final db = await database;
      await db.update(
        'usuarios',
        {'status': 'offline'},
        where: 'userid = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Erro ao fazer logout: $e');
      throw Exception('Falha ao fazer logout');
    }
  }
}

extension MessageOperations on DatabaseHelper {
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM mensagens
        WHERE cidadaoId = ? AND lida = ? 
      ''', [userId, 'false']);

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Erro ao buscar mensagens não lidas: $e');
      throw Exception('Falha ao buscar mensagens não lidas');
    }
  }

  Future<void> clearUserSession(String userId) async {
    // Aqui você pode adicionar lógica adicional de limpeza se necessário
    print('Sessão do usuário $userId encerrada');
  }
}
