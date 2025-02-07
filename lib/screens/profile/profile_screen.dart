// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Usuario user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = DatabaseHelper.instance.getUserStats(widget.user.userid);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.deleteUsuario(widget.user.userid);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir conta')),
                  );
                }
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedUser = await Navigator.push<Usuario>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: widget.user),
                ),
              );
              if (updatedUser != null) {
                setState(() {
                  // Atualizar dados do usuário se necessário
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do Perfil
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: Text(
                          widget.user.nome[0].toUpperCase(),
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildProfileField('Nome', widget.user.nome),
                    _buildProfileField('Email', widget.user.email),
                    _buildProfileField('Telefone', widget.user.telefone),
                    _buildProfileField('Tipo de Usuário', widget.user.tipoDeUsuario),
                    _buildProfileField('Localização', widget.user.localizacao),
                    _buildProfileField('Data de Cadastro', widget.user.dataCadastro),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Estatísticas
            Text(
              'Estatísticas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar estatísticas'));
                }

                final stats = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Total de Trabalhos', stats['totalTrabalhos'].toString()),
                    _buildStatCard('Trabalhos Pendentes', stats['trabalhosPendentes'].toString()),
                    _buildStatCard('Trabalhos Abertos', stats['trabalhosAbertos'].toString()),
                    _buildStatCard('Trabalhos Concluídos', stats['trabalhosConcluidos'].toString()),
                    _buildStatCard('Média de Avaliações', stats['mediaAvaliacoes'].toStringAsFixed(1)),
                    _buildStatCard('Total de Propostas', stats['totalPropostas'].toString()),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            
            // Botão de Excluir Conta
            Center(
              child: ElevatedButton.icon(
                onPressed: _showDeleteConfirmation,
                icon: Icon(Icons.delete_forever, color: Colors.red),
                label: Text('Excluir Conta'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red[50],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}