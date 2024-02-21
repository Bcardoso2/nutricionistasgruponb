import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clipboard/clipboard.dart';

class RelatorioSemanalPage extends StatefulWidget {
  @override
  _RelatorioSemanalPageState createState() => _RelatorioSemanalPageState();
}

class _RelatorioSemanalPageState extends State<RelatorioSemanalPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String selectedUser = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _selectUser();
  }

  Future<void> _selectUser() async {
    final user = _auth.currentUser;
    setState(() {
      selectedUser = user?.displayName ?? '';
    });
  }

  Future<void> _selectDate({required TextEditingController controller}) async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: currentDate,
    );

    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório Semanal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _startDateController,
              inputFormatters: [maskFormatter],
              decoration: InputDecoration(
                labelText: 'Data Inicial (dd/mm/aaaa)',
                hintText: 'Informe a data',
              ),
              onTap: () {
                _selectDate(controller: _startDateController);
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _endDateController,
              inputFormatters: [maskFormatter],
              decoration: InputDecoration(
                labelText: 'Data Final (dd/mm/aaaa)',
                hintText: 'Informe a data',
              ),
              onTap: () {
                _selectDate(controller: _endDateController);
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              readOnly: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                await _generateTextReport();
              },
              child: Text('Gerar Relatório'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateTextReport() async {
    try {
      if (_startDateController.text.isEmpty ||
          _endDateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha as datas')),
        );
        return;
      }

      final startDate =
          DateFormat('dd/MM/yyyy').parse(_startDateController.text);
      final endDate = DateFormat('dd/MM/yyyy').parse(_endDateController.text);

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('visitas')
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('data', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      StringBuffer reportBuffer = StringBuffer();
      reportBuffer.writeln('Relatório Semanal de Visitas');
      reportBuffer.writeln('Usuário: $selectedUser');
      reportBuffer.writeln('Data Inicial: ${_startDateController.text}');
      reportBuffer.writeln('Data Final: ${_endDateController.text}');
      reportBuffer.writeln('');

      for (var doc in snapshot.docs) {
        final visitData = doc.data() as Map<String, dynamic>;
        final Timestamp timestamp = visitData['data'] as Timestamp;
        final DateTime visitDateTime = timestamp.toDate();
        final String visitTitle =
            visitData['titulo'] ?? 'Título não disponível';
        final String visitLocation =
            visitData['local'] ?? 'Localização não disponível';
        final double visitLatitude = visitData['latitude'] ?? 0.0;
        final double visitLongitude = visitData['longitude'] ?? 0.0;

        reportBuffer.writeln('Visita: $visitTitle');
        reportBuffer
            .writeln('Data: ${DateFormat('dd/MM/yyyy').format(visitDateTime)}');
        reportBuffer.writeln('Local: $visitLocation');
        reportBuffer.writeln('Latitude: $visitLatitude');
        reportBuffer.writeln('Longitude: $visitLongitude');
        reportBuffer.writeln('');
      }

      FlutterClipboard.copy(reportBuffer.toString()).then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Relatório copiado para a área de transferência')),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    }
  }
}
