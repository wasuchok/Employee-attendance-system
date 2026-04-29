import 'package:flutter/material.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forbidden')),
      body: const Center(
        child: Text(
          'You do not have permission to access this page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
