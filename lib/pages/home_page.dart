import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutris_nb/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final senha = TextEditingController();

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool acao) {
    setState(() {
      isLogin = acao;
      if (isLogin) {
        titulo = 'Bem vindo';
        actionButton = 'Login';
        toggleButton = 'Cadastrar novo usuário';
      } else {
        titulo = 'Crie sua conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Voltar ao Login.';
      }
    });
  }

  login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  registrar() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().registrar(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/pw/ADCreHeu5ZJW56Fr54sFuhR-WC-co3iFEEMLH6c4MhRbun7LpSRFuY2gWZowT9Pav7jUlbA_H9_KgolwDZ8fwCLpzIq__-SNjyyyLRzhOunL6AUG8borfxyv0Q5xoMTL30EGTBG4ZGvXHp31hVO6i-YqTyrV2A=w1306-h924-s-no?authuser=0'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Informe o email corretamente!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: senha,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Informa sua senha!';
                        } else if (value.length < 6) {
                          return 'Sua senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isLogin) {
                            login();
                          } else {
                            registrar();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: (loading)
                            ? [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ]
                            : [
                                Icon(Icons.check),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    actionButton,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => setFormAction(!isLogin),
                      child: Text(toggleButton),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
