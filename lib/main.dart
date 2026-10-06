import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/obd_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ObdService(),
      child: const Obd2App(),
    ),
  );
}

class Obd2App extends StatelessWidget {
  const Obd2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBD2 Scanner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[700]!,
          secondary: Colors.greenAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
