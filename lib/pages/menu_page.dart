import 'package:flutter/material.dart';
import 'package:nutris_nb/pages/cronograma_semanal_page.dart';
import 'package:nutris_nb/pages/entrega_amostra.dart';
import 'package:provider/provider.dart';
import 'cadastro_page.dart';
import 'relatorio_semanal.dart';
import '../services/auth_service.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    CadastroPage(),
    RelatorioSemanalPage(),
    CronogramaSemanalPage(),
    EntregasAmostraPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Relatório',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Cronograma',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Entregas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey, // Defina a cor para cinza
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
