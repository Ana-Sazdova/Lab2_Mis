import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void addFavorite(Map<String, dynamic> joke) {
    if (!_favorites.contains(joke)) {
      _favorites.add(joke);
      notifyListeners();
    }
  }

  void removeFavorite(Map<String, dynamic> joke) {
    _favorites.remove(joke);
    notifyListeners();
  }

  bool isFavorite(Map<String, dynamic> joke) {
    return _favorites.contains(joke);
  }
}
