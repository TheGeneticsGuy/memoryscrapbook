// This will be the screen that is navigated to to create a new memory, off the home page.

import 'package:flutter/material.dart';

class CreateMemoryScreen extends StatelessWidget {
  const CreateMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Memory'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Form to Create Memory'),
      ),
    );
  }
}