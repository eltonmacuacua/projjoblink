// lib/screens/professional_profiles/professional_profiles_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';

class ProfessionalProfilesScreen extends StatelessWidget {
  const ProfessionalProfilesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfis de Profissionais'),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: DatabaseHelper.instance.getProfessionalUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar perfis: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Nenhum profissional encontrado'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final professional = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(professional.nome[0].toUpperCase()),
                  ),
                  title: Text(professional.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(professional.especializacao),
                      Text(professional.localizacao),
                    ],
                  ),
                  onTap: () {
                    // Aqui você pode navegar para uma tela de detalhes do profissional
                    // Navigator.push(context, MaterialPageRoute(...));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}