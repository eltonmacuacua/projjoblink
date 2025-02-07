// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database/sqlite_helper.dart';

class NotificationsScreen extends StatefulWidget {
  final Usuario user;

  const NotificationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getMessages(widget.user.userid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma notificação encontrada'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.notifications),
                ),
                title: Text(message['conteudo'] ?? ''),
                subtitle: Text(message['dataEnvio'] ?? ''),
                trailing: message['lida'] == 'false'
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                onTap: () async {
                  // Marcar como lida ao clicar
                  await DatabaseHelper.instance
                      .markMessageAsRead(message['mensagemId']);
                  // Atualizar a lista
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}