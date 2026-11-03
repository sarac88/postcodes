import 'package:flutter/material.dart';
import 'package:postcodes/models/place.dart';
import 'package:postcodes/styles/app_styles.dart';

class PlaceInformationCard extends StatelessWidget {
  const PlaceInformationCard({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          children: [
            _PlaceInformationRow(
              icon: Icons.map_outlined,
              label: 'Provincia',
              value: place.admin2 ?? 'No disponible',
            ),
            const Divider(),
            _PlaceInformationRow(
              icon: Icons.terrain_rounded,
              label: 'Comunidad',
              value: place.admin1 ?? 'No disponible',
            ),
            const Divider(),
            _PlaceInformationRow(
              icon: Icons.people_alt_outlined,
              label: 'Habitantes',
              value: place.population == null
                  ? 'No disponible'
                  : '${_formatPopulation(place.population!)} habitantes',
            ),
            const Divider(),
            _PlaceInformationRow(
              icon: Icons.my_location_rounded,
              label: 'Coordenadas',
              value: '${place.latitude}, ${place.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatPopulation(int population) {
    return population.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }
}

class _PlaceInformationRow extends StatelessWidget {
  const _PlaceInformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppStyles.palePrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppStyles.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: AppStyles.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppStyles.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
