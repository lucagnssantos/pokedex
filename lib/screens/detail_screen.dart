import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/captured_provider.dart';
import '../services/pokeapi_service.dart';

/// Tela de detalhes. Pode receber um [nameOrId] para buscar na API,
/// ou já vir com [preloadedDetail] pronto (ex: vindo da busca).
class DetailScreen extends StatefulWidget {
  final String? nameOrId;
  final PokemonDetail? preloadedDetail;

  const DetailScreen({super.key, this.nameOrId, this.preloadedDetail})
      : assert(nameOrId != null || preloadedDetail != null,
            'Informe nameOrId ou preloadedDetail');

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _api = PokeApiService();
  late Future<PokemonDetail> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = widget.preloadedDetail != null
        ? Future.value(widget.preloadedDetail)
        : _api.fetchPokemonDetail(widget.nameOrId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: FutureBuilder<PokemonDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Ocorreu um erro ao carregar os detalhes.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final pokemon = snapshot.data!;
          return _DetailBody(pokemon: pokemon);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final PokemonDetail pokemon;
  const _DetailBody({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final captured = context.watch<CapturedProvider>();
    final isFav = favorites.isFavorite(pokemon.id);
    final isCaptured = captured.isCaptured(pokemon.id);
    final displayName =
        pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Semantics(
              label: 'Imagem grande de $displayName',
              child: Image.network(
                pokemon.imageUrl,
                height: 220,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 80,
                  semanticLabel: 'Imagem indisponível',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: pokemon.types
                .map((t) => Chip(label: Text(t.toUpperCase())))
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBlock(label: 'Altura', value: '${pokemon.heightMeters} m'),
              _StatBlock(label: 'Peso', value: '${pokemon.weightKg} kg'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Habilidades',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(pokemon.abilities.join(', ')),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Semantics(
                    button: true,
                    label: isFav
                        ? 'Remover $displayName dos favoritos'
                        : 'Adicionar $displayName aos favoritos',
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<FavoritesProvider>().toggleFavorite(pokemon),
                      icon: Icon(isFav ? Icons.star : Icons.star_border),
                      label: Text(isFav ? 'Favorito' : 'Favoritar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFav ? Colors.amber : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Semantics(
                    button: true,
                    label: isCaptured
                        ? 'Desmarcar $displayName como capturado'
                        : 'Marcar $displayName como capturado',
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .read<CapturedProvider>()
                          .toggleCaptured(pokemon),
                      icon: Icon(isCaptured
                          ? Icons.catching_pokemon
                          : Icons.circle_outlined),
                      label: Text(isCaptured ? 'Capturado' : 'Capturar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCaptured ? Colors.green : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
