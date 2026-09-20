/// Representa um Pokémon na lista do catálogo (dados resumidos).
class PokemonSummary {
  final String name;
  final String url;
  final int id;

  PokemonSummary({required this.name, required this.url, required this.id});

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    // A URL tem o formato .../pokemon/25/ -> extraímos o id para montar a imagem
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.tryParse(segments.last) ?? 0;

    return PokemonSummary(
      name: json['name'] as String,
      url: url,
      id: id,
    );
  }

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

/// Representa os detalhes completos de um Pokémon (RF03).
class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int heightDecimeters;
  final int weightHectograms;
  final List<String> abilities;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.heightDecimeters,
    required this.weightHectograms,
    required this.abilities,
  });

  double get heightMeters => heightDecimeters / 10;
  double get weightKg => weightHectograms / 10;

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final officialArt = json['sprites']?['other']?['official-artwork']
        ?['front_default'] as String?;
    final fallbackImage = json['sprites']?['front_default'] as String?;

    return PokemonDetail(
      id: id,
      name: json['name'] as String,
      imageUrl: officialArt ??
          fallbackImage ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      heightDecimeters: json['height'] as int,
      weightHectograms: json['weight'] as int,
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
    );
  }

  /// Converte para/de um Map simples, usado para persistência local
  /// (favoritos e capturados são guardados como JSON simplificado).
  Map<String, dynamic> toStorageMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'types': types,
        'height': heightDecimeters,
        'weight': weightHectograms,
        'abilities': abilities,
      };

  factory PokemonDetail.fromStorageMap(Map<String, dynamic> map) {
    return PokemonDetail(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      types: List<String>.from(map['types'] as List),
      heightDecimeters: map['height'] as int,
      weightHectograms: map['weight'] as int,
      abilities: List<String>.from(map['abilities'] as List),
    );
  }
}
