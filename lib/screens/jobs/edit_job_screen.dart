// lib/screens/jobs/edit_job_screen.dart
import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../services/database/sqlite_helper.dart';

class EditJobScreen extends StatefulWidget {
  final Trabalho job;

  const EditJobScreen({Key? key, required this.job}) : super(key: key);

  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController tituloController;
  late TextEditingController descricaoController;
  late TextEditingController orcamentoController;
  late TextEditingController dataLimiteController;
  late TextEditingController localizacaoController;
  String? categoria;
  String? status;

  // Definindo as listas de opções
  final List<String> categorias = [
    'Design',
    'Desenvolvimento',
    'Marketing',
    'Outros'
  ];

  final List<String> statusOptions = [
    'Aberto',
    'Em Andamento',
    'Concluído',
    'Cancelado'
  ];

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.job.titulo);
    descricaoController = TextEditingController(text: widget.job.descricao);
    orcamentoController = TextEditingController(text: widget.job.orcamento);
    dataLimiteController = TextEditingController(text: widget.job.dataLimite);
    localizacaoController = TextEditingController(text: widget.job.localizacao);
    
    // Verificar se os valores iniciais existem nas listas de opções
    if (categorias.contains(widget.job.categoria)) {
      categoria = widget.job.categoria;
    } else {
      categoria = categorias.first; // Valor padrão se não encontrar
    }

    if (statusOptions.contains(widget.job.status)) {
      status = widget.job.status;
    } else {
      status = statusOptions.first; // Valor padrão se não encontrar
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    orcamentoController.dispose();
    dataLimiteController.dispose();
    localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    if (categoria == null || status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    try {
      final updatedJob = Trabalho(
        jobId: widget.job.jobId,
        titulo: tituloController.text,
        descricao: descricaoController.text,
        categoria: categoria!,
        orcamento: orcamentoController.text,
        dataCriacao: widget.job.dataCriacao,
        dataLimite: dataLimiteController.text,
        cidadaoId: widget.job.cidadaoId,
        prazo: widget.job.prazo,
        status: status!,
        localizacao: localizacaoController.text,
      );

      await DatabaseHelper.instance.updateTrabalho(updatedJob);
      Navigator.pop(context, updatedJob);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar trabalho: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Trabalho'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: categoria,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: categorias.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  categoria = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: orcamentoController,
              decoration: InputDecoration(
                labelText: 'Orçamento',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: dataLimiteController,
              decoration: InputDecoration(
                labelText: 'Data Limite',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: localizacaoController,
              decoration: InputDecoration(
                labelText: 'Localização',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  status = newValue;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateJob,
              child: Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}