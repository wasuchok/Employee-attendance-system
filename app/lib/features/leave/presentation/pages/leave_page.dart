import 'package:flutter/material.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request')),
      body: Center(child: Text('Leave')),
    );
  }
}
