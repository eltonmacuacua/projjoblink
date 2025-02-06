// lib/screens/jobs/job_details_screen.dart
import 'package:flutter/material.dart';
import '../../models/job.dart';

class JobDetailsScreen extends StatelessWidget {
  final Trabalho job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Trabalho'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              job.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            _buildDetailRow('Descrição', job.descricao),
            _buildDetailRow('Categoria', job.categoria),
            _buildDetailRow('Orçamento', job.orcamento),
            _buildDetailRow('Data de Criação', job.dataCriacao),
            _buildDetailRow('Data Limite', job.dataLimite),
            _buildDetailRow('Status', job.status),
            _buildDetailRow('Localização', job.localizacao),
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