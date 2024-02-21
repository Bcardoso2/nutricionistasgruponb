import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  final Location _location = Location();
  double _latitude = 0.0;
  double _longitude = 0.0;

  void _selectDate() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  void _limparAssinatura() {
    _signatureController.clear();
  }

  Future<void> _salvarDadosNoFirestore() async {
    try {
      CollectionReference visitas =
          FirebaseFirestore.instance.collection('visitas');

      final DateTime data = _selectedDate;
      final String local = _localController.text;
      final String nome = _nomeController.text;
      final String assunto = _assuntoController.text;
      final Uint8List? signatureData = await _signatureController.toPngBytes();

      await visitas.add({
        'data': data,
        'local': local,
        'nome': nome,
        'assunto': assunto,
        'assinatura':
            signatureData != null ? FieldValue.arrayUnion(signatureData) : null,
        'latitude': _latitude,
        'longitude': _longitude,
      });

      // Exiba uma mensagem de sucesso ou redirecione para a próxima tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dados salvos com sucesso!'),
        ),
      );

      // Limpe os campos após o salvamento
      _localController.clear();
      _nomeController.clear();
      _assuntoController.clear();
      _signatureController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    } catch (e) {
      print('Erro ao salvar os dados: $e');
    }
  }

  void _fazerCheckin() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }

    LocationData? locationData = await _location.getLocation();
    _latitude = locationData!.latitude!;
    _longitude = locationData.longitude!;

    // Exiba a Snackbar informando que a localização foi obtida com sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Localização obtida com sucesso.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Visitas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text('Data'),
                subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year.toString()}'),
                onTap: _selectDate,
              ),
              TextFormField(
                controller: _localController,
                decoration: InputDecoration(labelText: 'Local'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _assuntoController,
                decoration: InputDecoration(labelText: 'Assunto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: _limparAssinatura,
                child: Text('Limpar campo de assinatura'),
              ),
              ElevatedButton(
                onPressed: _fazerCheckin,
                child: Text('Fazer Check-in'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    await _salvarDadosNoFirestore();
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
