import 'package:flutter/material.dart';
import 'package:postcodes/models/place.dart';
import 'package:postcodes/styles/app_styles.dart';

class PlaceResultCard extends StatelessWidget {
  const PlaceResultCard({
    super.key,
    required this.place,
    required this.postalCodes,
    required this.onTap,
  });

  final Place place;
  final String postalCodes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final location = [place.admin2, place.admin1]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(' · ');

    return Card(
      child: ListTile(
        key: ValueKey(place.id),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: const CircleAvatar(
          backgroundColor: AppStyles.palePrimary,
          foregroundColor: AppStyles.primary,
          child: Icon(Icons.location_city_rounded),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppStyles.textSecondary,
        ),
        onTap: onTap,
        title: Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppStyles.textPrimary,
            ),
            children: [
              TextSpan(
                text: '$postalCodes  ',
                style: const TextStyle(
                  color: AppStyles.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: place.name),
            ],
          ),
        ),
        subtitle: location.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  location,
                  style: const TextStyle(color: AppStyles.textSecondary),
                ),
              ),
      ),
    );
  }
}
