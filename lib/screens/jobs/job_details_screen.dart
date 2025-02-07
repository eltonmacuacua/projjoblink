// lib/screens/jobs/job_details_screen.dart
import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../models/proposal.dart';
import '../../services/database/sqlite_helper.dart';
import 'edit_job_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final Trabalho job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Trabalho currentJob;

  @override
  void initState() {
    super.initState();
    currentJob = widget.job;
  }

  Future<void> _deleteJob() async {
    try {
      await DatabaseHelper.instance.deleteTrabalho(currentJob.jobId);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar trabalho')),
      );
    }
  }

  Future<void> _editJob() async {
    final updatedJob = await Navigator.push<Trabalho>(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobScreen(job: currentJob),
      ),
    );

    if (updatedJob != null) {
      setState(() {
        currentJob = updatedJob;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir este trabalho?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteJob();
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
        title: Text('Detalhes do Trabalho'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editJob,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentJob.titulo,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Descrição', currentJob.descricao),
                    _buildDetailRow('Categoria', currentJob.categoria),
                    _buildDetailRow('Orçamento', currentJob.orcamento),
                    _buildDetailRow('Data de Criação', currentJob.dataCriacao),
                    _buildDetailRow('Data Limite', currentJob.dataLimite),
                    _buildDetailRow('Status', currentJob.status),
                    _buildDetailRow('Localização', currentJob.localizacao),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Propostas Recebidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Proposta>>(
                future: DatabaseHelper.instance
                    .getPropostasByTrabalho(currentJob.jobId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar propostas'),
                    );
                  }

                  final propostas = snapshot.data ?? [];

                  if (propostas.isEmpty) {
                    return Center(
                      child: Text('Nenhuma proposta recebida ainda'),
                    );
                  }

                  return ListView.builder(
                    itemCount: propostas.length,
                    itemBuilder: (context, index) {
                      final proposta = propostas[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('Valor: ${proposta.valor}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(proposta.descricao),
                              Text(
                                'Data: ${proposta.dataProposta}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(proposta.status),
                            backgroundColor: proposta.status == 'Aceita'
                                ? Colors.green[100]
                                : Colors.grey[100],
                          ),
                          onTap: () {
                            // Implementar visualização detalhada da proposta
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}