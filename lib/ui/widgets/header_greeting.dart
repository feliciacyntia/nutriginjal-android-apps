import 'package:flutter/material.dart';

class HeaderGreeting extends StatelessWidget {
  final String userName;
  const HeaderGreeting({required this.userName, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang, $userName!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Semoga sehat selalu. Berikut ringkasan kesehatan Anda.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
