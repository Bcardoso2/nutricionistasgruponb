import 'package:nutris_nb/widgets/auth_check.dart';
import 'package:flutter/material.dart';

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutricionistas Grupo NB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            createMaterialColor(Color(0xFFA08B34)), // Cor personalizada
        textTheme: TextTheme(
          headline1: TextStyle(
              color: Colors.black), // Ajuste a cor do texto conforme necessário
          headline2: TextStyle(color: Colors.black),
          headline3: TextStyle(color: Colors.black),
          headline4: TextStyle(color: Colors.black),
          headline5: TextStyle(color: Colors.black),
          headline6: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.black),
          subtitle2: TextStyle(color: Colors.black),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
          button: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
          overline: TextStyle(color: Colors.black),
        ),
      ),
      home: AuthCheck(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (double i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
