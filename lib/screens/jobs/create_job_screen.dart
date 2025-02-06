// lib/screens/jobs/create_job_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/job.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';

class CreateJobScreen extends StatefulWidget {
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  late Usuario _currentUser;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _orcamentoController = TextEditingController();
  final TextEditingController _dataLimiteController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();

  String _status = 'Pendente';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract user from route arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Usuario) {
      _currentUser = args;
    } else {
      // Handle case where user is not passed
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Novo Trabalho')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título do Trabalho'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(labelText: 'Categoria'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _orcamentoController,
                decoration: InputDecoration(labelText: 'Orçamento'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _dataLimiteController,
                decoration: InputDecoration(labelText: 'Data Limite'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dataLimiteController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(labelText: 'Localização'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitJob,
                child: Text('Criar Trabalho'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoTrabalho = Trabalho(
          jobId: Uuid().v4(),
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          categoria: _categoriaController.text,
          orcamento: _orcamentoController.text,
          dataCriacao: DateTime.now().toIso8601String(),
          dataLimite: _dataLimiteController.text,
          cidadaoId: _currentUser.userid,
          prazo: _dataLimiteController.text,
          status: _status,
          localizacao: _localizacaoController.text,
        );

        await DatabaseHelper.instance.insertTrabalho(novoTrabalho);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trabalho criado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar trabalho: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _orcamentoController.dispose();
    _dataLimiteController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }
}
