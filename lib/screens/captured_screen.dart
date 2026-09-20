import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/captured_provider.dart';
import 'detail_screen.dart';

class CapturedScreen extends StatelessWidget {
  const CapturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final captured = context.watch<CapturedProvider>().captured;

    return Scaffold(
      appBar: AppBar(title: const Text('Capturados')),
      body: captured.isEmpty
          ? const Center(child: Text('Você ainda não capturou nenhum Pokémon.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: captured.length,
              itemBuilder: (context, index) {
                final pokemon = captured[index];
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
                      icon: const Icon(Icons.catching_pokemon,
                          color: Colors.green),
                      tooltip: 'Desmarcar como capturado',
                      onPressed: () => context
                          .read<CapturedProvider>()
                          .toggleCaptured(pokemon),
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
