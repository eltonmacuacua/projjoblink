import 'package:flutter/material.dart';
import 'screens/auth/register_screen.dart';
import 'package:sqflite/sqflite_dev.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  if ()
 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobLink - CLientes',
      theme: ThemeData(       
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterScreen(),
      },
    );
  }
}
