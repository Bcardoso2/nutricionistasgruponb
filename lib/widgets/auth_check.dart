import 'package:nutris_nb/pages/home_page.dart';
import 'package:nutris_nb/pages/menu_page.dart';
import 'package:nutris_nb/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading)
      return loading();
    else if (auth.usuario == null)
      return LoginPage();
    else
      return MenuPage();
  }

  loading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
