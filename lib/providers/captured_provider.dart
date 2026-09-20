import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

/// RF07 — lista de itens "consumidos" (aqui, "capturados").
/// Persistida localmente, igual aos favoritos.
class CapturedProvider extends ChangeNotifier {
  static const _storageKey = 'captured_pokemon_list';

  final Map<int, PokemonDetail> _captured = {};

  List<PokemonDetail> get captured => _captured.values.toList();

  bool isCaptured(int id) => _captured.containsKey(id);

  Future<void> loadCaptured() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final List decoded = jsonDecode(raw) as List;
    _captured.clear();
    for (final item in decoded) {
      final detail =
          PokemonDetail.fromStorageMap(item as Map<String, dynamic>);
      _captured[detail.id] = detail;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _captured.values.map((p) => p.toStorageMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> toggleCaptured(PokemonDetail pokemon) async {
    if (_captured.containsKey(pokemon.id)) {
      _captured.remove(pokemon.id);
    } else {
      _captured[pokemon.id] = pokemon;
    }
    notifyListeners();
    await _persist();
  }
}
