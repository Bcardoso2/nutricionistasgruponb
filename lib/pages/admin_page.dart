import 'package:flutter/material.dart';
import 'package:nutris_nb/pages/tracker_page.dart';

class AdminPage extends StatelessWidget {
  final List<String> users = [
    'diogo',
    'bricio',
    'bruno'
  ]; // Lista de usuários cadastrados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Administração'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final username = users[index];
          return ListTile(
            title: Text(username),
            onTap: () {
              // Ao tocar em um nome de usuário, redirecione para a tela de rastreamento
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserTrackingPage(username: username),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
