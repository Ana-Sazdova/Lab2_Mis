import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_services.dart';
import 'joke_type.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<String>> _jokeTypes;

  @override
  void initState() {
    super.initState();
    _jokeTypes = ApiService.fetchJokeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Joke Types"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.sentiment_very_satisfied),
            onPressed: () {
              Navigator.pushNamed(context, '/random-joke');
            },
          ),
        ],

      ),
      body: FutureBuilder<List<String>>(
        future: _jokeTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No joke types found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final jokeType = snapshot.data![index];
                return ListTile(
                  title: Text(jokeType),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JokeTypeScreen(jokeType: jokeType),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}