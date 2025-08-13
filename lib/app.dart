import 'package:flutter/material.dart';
import 'package:number_master_puzzle/features/game/data/presentation/screens/home_screen.dart';

class NumberMasterApp extends StatelessWidget {
  const NumberMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Master Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
