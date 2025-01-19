import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Jokes")),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorite jokes yet!"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final joke = favorites[index];
          return ListTile(
            title: Text(joke['setup']),
            subtitle: Text(joke['punchline']),
          );
        },
      ),
    );
  }
}
