import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutris_nb/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'meu_aplicativo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()),
      ],
      child: MeuAplicativo(),
    ),
  );
}
