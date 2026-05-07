import 'package:flutter/material.dart';

class SuggestedPromptButtons extends StatelessWidget {
  final List<String> prompts;
  final void Function(String) onPromptSelected;
  const SuggestedPromptButtons({required this.prompts, required this.onPromptSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: prompts.map((prompt) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFE0F7FA),
          side: const BorderSide(color: Color(0xFFB2EBF2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () => onPromptSelected(prompt),
        child: Text(
          prompt,
          style: const TextStyle(color: Color(0xFF00838F), fontSize: 13, fontWeight: FontWeight.w500),
        ),
      )).toList(),
    );
  }
}
