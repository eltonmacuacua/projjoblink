import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController especializacaoController;
  late TextEditingController localizacaoController;
  String? tipoDeUsuario;

  // Modificado para usar as mesmas strings que estão no banco de dados
  final List<String> tiposDeUsuario = ['cidadao', 'freelancer'];

  // Função auxiliar para exibir o texto formatado no dropdown
  String formatTipoUsuario(String tipo) {
    switch (tipo) {
      case 'cidadao':
        return 'Cidadão';
      case 'freelancer':
        return 'Freelancer';
      default:
        return tipo;
    }
  }

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.user.nome);
    emailController = TextEditingController(text: widget.user.email);
    telefoneController = TextEditingController(text: widget.user.telefone);
    especializacaoController = TextEditingController(text: widget.user.especializacao);
    localizacaoController = TextEditingController(text: widget.user.localizacao);
    tipoDeUsuario = widget.user.tipoDeUsuario;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    especializacaoController.dispose();
    localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      final updatedUser = Usuario(
        userid: widget.user.userid,
        nome: nomeController.text,
        email: emailController.text,
        senha: widget.user.senha,
        telefone: telefoneController.text,
        tipoDeUsuario: tipoDeUsuario ?? widget.user.tipoDeUsuario,
        especializacao: especializacaoController.text,
        dataCadastro: widget.user.dataCadastro,
        localizacao: localizacaoController.text,
      );

      await DatabaseHelper.instance.updateUsuario(updatedUser);
      Navigator.pop(context, updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
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
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Atualizar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}