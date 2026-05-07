import 'package:flutter/material.dart';

class InfoArticleCard extends StatelessWidget {
  final String title;
  final String content;
  const InfoArticleCard({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFE0F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF26C6DA))),
            SizedBox(height: 6),
            Text(content, style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
