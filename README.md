# Nomes

Eduardo Jabur Chede Malaghin.
Fabio Henrique Spiller Veloso
Lucas Gabriel Nunes dos Santos
Vinícius Wamser Gogoglla 

----------------------------------------------

# Pokédex Catálogo (Flutter + PokéAPI)

Projeto somativo de catálogo interativo, usando a [PokéAPI](https://pokeapi.co/) como
API pública gratuita.

## Como rodar

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Extraia este zip e abra a pasta no VS Code ou Android Studio.
3. No terminal, dentro da pasta do projeto:
   ```bash
   flutter pub get
   flutter run
   ```
4. Escolha um emulador/dispositivo conectado quando solicitado.

## Estrutura

```
lib/
  models/
    pokemon.dart          -> PokemonSummary (lista) e PokemonDetail (detalhe)
  services/
    pokeapi_service.dart  -> chamadas HTTP (lista paginada, detalhe, busca)
  providers/
    auth_provider.dart       -> login/cadastro local (RF07 baseline)
    favorites_provider.dart  -> favoritos + persistência (RF04/05/06)
    captured_provider.dart   -> "capturados" + persistência (RF07)
  screens/
    login_screen.dart     -> RF07
    catalog_screen.dart   -> RF01, RF02, RF08, RF09, RF10
    detail_screen.dart    -> RF03, RF04, RF07, RF09, RF10
    favorites_screen.dart -> RF05
    captured_screen.dart  -> RF07
  main.dart                -> providers globais + roteamento condicional
```

## Mapeamento dos Requisitos Funcionais

| RF | Onde está implementado |
|----|--------------------------|
| RF01 — Catálogo em grid + "Carregar Mais" | `catalog_screen.dart` (`GridView`/`SliverGrid`, `_loadMore`) |
| RF02 — Navegação para detalhes | `catalog_screen.dart` -> `Navigator.push` para `DetailScreen` |
| RF03 — Tela de detalhes | `detail_screen.dart` + `pokeapi_service.fetchPokemonDetail` |
| RF04 — Favoritar com Provider | `favorites_provider.dart` + botão em `detail_screen.dart` |
| RF05 — Tela de Favoritos | `favorites_screen.dart` |
| RF06 — Persistência local | `shared_preferences` em `favorites_provider.dart` e `captured_provider.dart` |
| RF07 — Login local + "Capturados" | `auth_provider.dart`, `login_screen.dart`, `captured_provider.dart`, `captured_screen.dart` |
| RF08 — Busca | Campo de busca em `catalog_screen.dart` -> `pokeapi_service.searchPokemon` |
| RF09 — Feedback de UI | `CircularProgressIndicator` em login, carregamento, "Carregar Mais", busca; `FutureBuilder` em `detail_screen.dart`; mensagens de erro amigáveis via `ApiException` |
| RF10 — Acessibilidade | `Semantics`/`semanticLabel` nas imagens e botões; `textScaler` respeitado em `main.dart`; áreas de toque com altura mínima de 48px; contraste de texto definido no `ThemeData` |

## Observações importantes

- **Login (RF07 baseline)**: não é autenticação real. O primeiro cadastro
  feito fica salvo localmente (`shared_preferences`) e é usado para validar
  logins futuros. Isso já atende ao requisito — o foco pedido é a navegação
  condicional e o gerenciamento do estado de sessão, não segurança real.
- **Imagens**: usamos as artes oficiais dos Pokémon
  (`official-artwork`), com fallback para o sprite padrão e, por fim, para
  um ícone de "imagem indisponível" — a tela nunca quebra por falta de imagem.
- **Bônus (não implementado)**: sincronização em nuvem (Firebase/Supabase)
  e autenticação real ficam como próximos passos, caso vocês queiram os
  +10%/+10% extras. A estrutura de providers já foi pensada para facilitar
  essa troca depois (bastaria substituir a implementação interna dos
  providers, mantendo a mesma interface pública).

## Testando acessibilidade

- Ative o TalkBack (Android) ou VoiceOver (iOS) e navegue pelo catálogo e
  pela tela de detalhes: todos os elementos interativos têm rótulos
  descritivos.
- Aumente a fonte do sistema (Configurações > Acessibilidade > Tamanho da
  fonte) e confira que os cards e textos continuam legíveis, sem cortes.
