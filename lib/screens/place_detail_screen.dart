import 'package:flutter/material.dart';
import 'package:postcodes/models/place.dart';
import 'package:postcodes/styles/app_styles.dart';
import 'package:postcodes/widgets/place_information_card.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.screenPadding),
        children: [
          PlaceInformationCard(place: place),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: AppStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.markunread_mailbox_outlined,
                        color: AppStyles.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Códigos postales',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppStyles.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (place.postcodes.isEmpty)
                    const Text(
                      'No hay códigos postales disponibles.',
                      style: TextStyle(color: AppStyles.textSecondary),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final postcode in place.postcodes)
                          Chip(label: Text(postcode)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
