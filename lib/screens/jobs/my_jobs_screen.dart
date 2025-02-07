// lib/screens/jobs/my_jobs_screen.dart
import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';
import 'job_details_screen.dart';

class MyJobsScreen extends StatefulWidget {
  final Usuario user;

  const MyJobsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MyJobsScreenState createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Aberto', 'Em Andamento', 'Concluído'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Trabalhos'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _filters.map((String filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: DatabaseHelper.instance.getUserStats(widget.user.userid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data!;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total', stats['totalTrabalhos'].toString()),
                            _buildStatItem('Em Andamento', stats['trabalhosPendentes'].toString()),
                            _buildStatItem('Concluídos', stats['trabalhosConcluidos'].toString()),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Trabalho>>(
              future: DatabaseHelper.instance.getTrabalhosByCidadao(widget.user.userid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Nenhum trabalho encontrado'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create_job', arguments: widget.user);
                          },
                          child: Text('Criar Novo Trabalho'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredJobs = _selectedFilter == 'Todos'
                    ? snapshot.data!
                    : snapshot.data!.where((job) => job.status == _selectedFilter).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        title: Text(
                          job.titulo,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(job.descricao),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16),
                                SizedBox(width: 4),
                                Text('Prazo: ${job.prazo}'),
                                SizedBox(width: 16),
                                Icon(Icons.attach_money, size: 16),
                                SizedBox(width: 4),
                                Text('Orçamento: ${job.orcamento}'),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(job.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.status,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(job: job),
                            ),
                          ).then((_) {
                            // Atualiza a lista quando retornar da tela de detalhes
                            setState(() {});
                          });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_job', arguments: widget.user)
              .then((_) => setState(() {}));
        },
        child: Icon(Icons.add),
        tooltip: 'Criar Novo Trabalho',
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aberto':
        return Colors.blue;
      case 'Em Andamento':
        return Colors.orange;
      case 'Concluído':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}