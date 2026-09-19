import "package:flutter/material.dart";

import "theme.dart";
import "screens/home_screen.dart";


void main() {
  runApp(const KataApp());
}


class KataApp extends StatelessWidget {
  const KataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notas V6",
      debugShowCheckedModeBanner: false,
      theme: buildKataTheme(),
      home: const HomeScreen(),
    );
  }
}
