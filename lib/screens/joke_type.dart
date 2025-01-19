import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../providers/favorites_provider.dart';

class JokeTypeScreen extends StatelessWidget {
  final String jokeType;

  const JokeTypeScreen({super.key, required this.jokeType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$jokeType Jokes")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchJokesByType(jokeType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No jokes found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final joke = snapshot.data![index];
                final isFavorite = context
                    .watch<FavoritesProvider>()
                    .isFavorite(joke);

                return ListTile(
                  title: Text(joke['setup']),
                  subtitle: Text(joke['punchline']),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      final favoritesProvider =
                      context.read<FavoritesProvider>();

                      if (isFavorite) {
                        favoritesProvider.removeFavorite(joke);
                      } else {
                        favoritesProvider.addFavorite(joke);
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
