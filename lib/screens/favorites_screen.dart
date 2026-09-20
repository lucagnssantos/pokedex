import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favorites.isEmpty
          ? const Center(child: Text('Você ainda não tem favoritos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final pokemon = favorites[index];
                final displayName =
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

                return Card(
                  child: ListTile(
                    leading: Image.network(
                      pokemon.imageUrl,
                      width: 48,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
                    title: Text(displayName),
                    subtitle: Text(pokemon.types.join(', ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      tooltip: 'Remover dos favoritos',
                      onPressed: () => context
                          .read<FavoritesProvider>()
                          .toggleFavorite(pokemon),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailScreen(preloadedDetail: pokemon),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
