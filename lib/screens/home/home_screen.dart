// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/job.dart';
import '../../services/database/sqlite_helper.dart';
import '../jobs/job_details_screen.dart';
import '../profile/profile_screen.dart';
import '../professional_profiles/professional_profiles_screen.dart';
import '../jobs/my_jobs_screen.dart';
import '../notifications/notifications_screen.dart';

int _unreadMessages = 0;

class HomeScreen extends StatelessWidget {
  final Usuario user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Saída'),
          content: Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.clearUserSession(user.userid);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: Text('Sair'),
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
        title: Text('JobLink - contratante'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(user: user),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(user.nome[0].toUpperCase()),
                  ),
                  SizedBox(height: 10),
                  Text(
                    user.nome,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Meus Trabalhos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyJobsScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Mensagens'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Perfis de Profissionais'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfessionalProfilesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                // Implementar navegação
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar Saída'),
                      content: Text('Tem certeza que deseja sair?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navega para a tela de login e limpa a pilha de navegação
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          },
                          child: Text('Sair'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, ${user.nome}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.add_circle,
                    color: Theme.of(context).primaryColor),
                title: Text('Criar Novo Trabalho'),
                onTap: () {
                  Navigator.pushNamed(context, '/create_job', arguments: user);
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Trabalhos Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: FutureBuilder<List<Trabalho>>(
                future:
                    DatabaseHelper.instance.getTrabalhosByCidadao(user.userid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum trabalho encontrado'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final job = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(job.titulo),
                          subtitle: Text(job.descricao),
                          trailing: Text(job.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailsScreen(job: job),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_job', arguments: user);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
