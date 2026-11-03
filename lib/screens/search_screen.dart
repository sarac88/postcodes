import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:postcodes/models/place.dart';
import 'package:postcodes/models/search_response.dart';
import 'package:postcodes/screens/place_detail_screen.dart';
import 'package:postcodes/styles/app_styles.dart';
import 'package:postcodes/widgets/place_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  Future<List<Place>>? resultsFuture;
  String? searchQuery;

  void clearSearch() {
    setState(() {
      searchController.clear();
      searchQuery = null;
      resultsFuture = null;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un código postal o una población.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      searchQuery = query;
      resultsFuture = loadResults(query);
    });
  }

  Future<List<Place>> loadResults(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '100',
      'language': 'es',
      'format': 'json',
      'countryCode': 'ES',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw SearchException(
          'No se pudo completar la búsqueda (HTTP ${response.statusCode}).',
        );
      }

      final places = searchResponseFromJson(response.body).results;
      return RegExp(r'^\d{5}$').hasMatch(query)
          ? places.where((place) => place.postcodes.contains(query)).toList()
          : places;
    } on TimeoutException {
      throw SearchException(
        'La búsqueda ha tardado demasiado. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw SearchException(
        'No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.',
      );
    } on FormatException {
      throw SearchException('El servicio devolvió una respuesta no válida.');
    } on TypeError {
      throw SearchException('El servicio devolvió una respuesta no válida.');
    } on SearchException {
      rethrow;
    }
  }

  String postalCodesFor(Place place) {
    final query = searchQuery;
    if (query != null && RegExp(r'^\d{5}$').hasMatch(query)) {
      return query;
    }
    if (place.postcodes.isEmpty) return 'Sin código postal';

    final codes = place.postcodes.take(3).join(', ');
    final remaining = place.postcodes.length - 3;
    return remaining > 0 ? '$codes y $remaining más' : codes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda de lugares')),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppStyles.palePrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: AppStyles.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encuentra tu lugar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppStyles.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Busca por población o código postal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppStyles.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: search,
              decoration: InputDecoration(
                labelText: 'Código postal o población',
                hintText: 'Ej. 28001 o Madrid',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: resultsFuture == null
                      ? 'Buscar'
                      : 'Limpiar búsqueda',
                  onPressed: resultsFuture == null
                      ? () => search(searchController.text)
                      : clearSearch,
                  icon: Icon(
                    resultsFuture == null ? Icons.arrow_forward : Icons.close,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: buildResults()),
          ],
        ),
      ),
    );
  }

  Widget buildResults() {
    final future = resultsFuture;
    if (future == null) return const SizedBox.shrink();

    return FutureBuilder<List<Place>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final message = snapshot.error is SearchException
              ? (snapshot.error as SearchException).message
              : 'Error al cargar las poblaciones.';
          return Center(child: Text(message, textAlign: TextAlign.center));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data;
        if (places == null) {
          return const Center(child: Text('No se pudieron cargar resultados.'));
        }
        if (places.isEmpty) {
          return Center(
            child: Text('No se encontraron poblaciones para «$searchQuery».'),
          );
        }

        return ListView.separated(
          itemCount: places.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final place = places[index];
            return PlaceResultCard(
              place: place,
              postalCodes: postalCodesFor(place),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PlaceDetailScreen(place: place),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class SearchException implements Exception {
  const SearchException(this.message);
  final String message;
}
