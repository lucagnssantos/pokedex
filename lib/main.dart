import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/captured_provider.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(
            create: (_) => FavoritesProvider()..loadFavorites()),
        ChangeNotifierProvider(
            create: (_) => CapturedProvider()..loadCaptured()),
      ],
      child: MaterialApp(
        title: 'Pokédex Catálogo',
        debugShowCheckedModeBanner: false,
        // RF10 — não trava o layout quando o usuário aumenta a fonte do
        // sistema; limitamos um pouco o fator máximo para não quebrar
        // grids/cards, mas sem impedir o aumento de texto.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final clampedScale =
              mediaQuery.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.6);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScale),
            child: child!,
          );
        },
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
          // RF10 — contraste adequado entre texto e fundo.
          textTheme: const TextTheme().apply(
            bodyColor: Colors.black87,
            displayColor: Colors.black87,
          ),
        ),
        home: const _RootRouter(),
      ),
    );
  }
}

/// RF07 — navegação condicional: só mostra o catálogo se houver sessão.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const CatalogScreen() : const LoginScreen();
  }
}
