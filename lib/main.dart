import 'package:flutter/material.dart';
import 'package:flutter_rick_and_morty/Listeleme_Karakterler.dart';

void main() {
  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListelemeKarakterler(),
      debugShowCheckedModeBanner: false,
    );
  }
}
