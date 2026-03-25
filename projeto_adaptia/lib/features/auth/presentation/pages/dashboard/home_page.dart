import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
<<<<<<< HEAD
  const HomePage({super.key});
=======
  const HomePage({super.key});
>>>>>>> main

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Bem-vindo ao seu dashboard! 🚀'),
        ],
      ),
    );
  }
}