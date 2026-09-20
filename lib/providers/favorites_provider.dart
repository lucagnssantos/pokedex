import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

/// RF04/RF05/RF06 — gerencia a lista de favoritos globalmente e
/// persiste no dispositivo com shared_preferences.
class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorites_pokemon_list';

  final Map<int, PokemonDetail> _favorites = {};

  List<PokemonDetail> get favorites => _favorites.values.toList();

  bool isFavorite(int id) => _favorites.containsKey(id);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final List decoded = jsonDecode(raw) as List;
    _favorites.clear();
    for (final item in decoded) {
      final detail =
          PokemonDetail.fromStorageMap(item as Map<String, dynamic>);
      _favorites[detail.id] = detail;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favorites.values.map((p) => p.toStorageMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> toggleFavorite(PokemonDetail pokemon) async {
    if (_favorites.containsKey(pokemon.id)) {
      _favorites.remove(pokemon.id);
    } else {
      _favorites[pokemon.id] = pokemon;
    }
    notifyListeners();
    await _persist();
  }
}
