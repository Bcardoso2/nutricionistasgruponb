import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronograma Semanal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CronogramaSemanalPage(),
    );
  }
}

class Compromisso {
  final String horario;
  final String descricao;

  Compromisso({required this.horario, required this.descricao});

  // Método para converter o Compromisso em um Map
  Map<String, dynamic> toMap() {
    return {
      'horario': horario,
      'descricao': descricao,
    };
  }
}

class CronogramaSemanalPage extends StatefulWidget {
  @override
  _CronogramaSemanalPageState createState() => _CronogramaSemanalPageState();
}

class _CronogramaSemanalPageState extends State<CronogramaSemanalPage> {
  late final Map<DateTime, List<Compromisso>> _events;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    // Carregar compromissos do Firebase inicialmente
    _loadCompromissos();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<Compromisso> _getEventsForDay(DateTime day) {
    return (_selectedDay != null && isSameDay(day, _selectedDay))
        ? _events[_selectedDay!] ?? []
        : [];
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addCompromissoToFirebase(Compromisso compromisso) async {
    // Referência para a coleção 'compromissos' no Firebase
    final collection = FirebaseFirestore.instance.collection('compromissos');

    // Converte o Compromisso para um Map
    final compromissoMap = compromisso.toMap();

    // Adiciona o Compromisso ao Firebase
    await collection.add(compromissoMap);
  }

  Future<void> _loadCompromissos() async {
    // Referência para a coleção 'compromissos' no Firebase
    final collection = FirebaseFirestore.instance.collection('compromissos');

    // Consulta os compromissos e atualiza o estado do aplicativo
    final querySnapshot = await collection.get();
    final compromissos = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Compromisso(
        horario: data['horario'],
        descricao: data['descricao'],
      );
    }).toList();

    setState(() {
      _events.clear();
      for (final compromisso in compromissos) {
        final date = _selectedDay ?? DateTime.now();
        _events.putIfAbsent(date, () => []).add(compromisso);
      }
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adicionar Compromisso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text("Horário: ${_selectedTime.format(context)}"),
              onTap: _showTimePicker,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Descrição'),
              controller: _descriptionController,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Adicionar'),
            onPressed: () async {
              if (_selectedDay != null) {
                final newEvent = Compromisso(
                  horario: _selectedTime.format(context),
                  descricao: _descriptionController.text,
                );

                // Adicione o novo Compromisso ao Firebase
                await _addCompromissoToFirebase(newEvent);

                setState(() {
                  _events.putIfAbsent(_selectedDay!, () => []).add(newEvent);
                  _descriptionController.clear();
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cronograma Semanal'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // Recarregar compromissos ao mudar a data
              // _loadCompromissos();
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => _getEventsForDay(day),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDay != null
                  ? (_events[_selectedDay!] ?? []).length
                  : 0,
              itemBuilder: (context, index) {
                final evento = _events[_selectedDay!]![index];
                return ListTile(
                  title: Text(evento.horario),
                  subtitle: Text(evento.descricao),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
