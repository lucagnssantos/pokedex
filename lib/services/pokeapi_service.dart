import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Exceção customizada para erros de comunicação com a API (RF09).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// RF01 — busca uma página da lista de pokémons.
  /// [offset] indica a partir de qual item começar e [limit] quantos trazer.
  Future<List<PokemonSummary>> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit');

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        throw ApiException(
            'Não foi possível carregar a lista de Pokémon (${response.statusCode}).');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;

      return results
          .map((item) =>
              PokemonSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Falha de conexão. Verifique sua internet e tente novamente.');
    }
  }

  /// RF03 — busca os detalhes completos de um pokémon pelo nome ou id.
  Future<PokemonDetail> fetchPokemonDetail(String nameOrId) async {
    final uri = Uri.parse(
        '$_baseUrl/pokemon/${nameOrId.toLowerCase().trim()}');

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 404) {
        throw ApiException('Pokémon "$nameOrId" não encontrado.');
      }
      if (response.statusCode != 200) {
        throw ApiException(
            'Não foi possível carregar os detalhes (${response.statusCode}).');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PokemonDetail.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Falha de conexão. Verifique sua internet e tente novamente.');
    }
  }

  /// RF08 — busca (é o mesmo endpoint de detalhe, já que a PokéAPI
  /// aceita nome exato como parâmetro de busca).
  Future<PokemonDetail> searchPokemon(String query) => fetchPokemonDetail(query);
}
