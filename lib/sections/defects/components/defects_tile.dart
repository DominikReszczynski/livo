import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/defect.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/sections/defects/components/defects_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DefectsTile extends StatelessWidget {
  final Defect defect;
  final DefectsProvider defectsProvider;

  const DefectsTile(
      {super.key, required this.defect, required this.defectsProvider});

  @override
  Widget build(BuildContext context) {
    final String urlPrefix = ApiService.baseUrl;

    final formattedDate = defect.createdAt != null
        ? DateFormat('dd-MM-yyyy').format(defect.createdAt!)
        : '';

    final imageUrl =
        (defect.imageFilenames != null && defect.imageFilenames!.isNotEmpty)
            ? "$urlPrefix/uploads/${defect.imageFilenames!.first}"
            : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DefectDetails(defect: defect, defectsProvider: defectsProvider),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Miniatura zdjęcia (jeśli istnieje)
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 24),
                      ),
                    ),
                  ),

                if (imageUrl != null) const SizedBox(width: 12),

                // 🔹 Lewa część – tekst
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defect.property?.location ?? 'Nieznane mieszkanie',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defect.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defect.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 🔹 Prawa część – data i status
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor(defect.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
