import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Categorias'),
      ),
      body: Center(
        child: Text(
          'Categorias',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
