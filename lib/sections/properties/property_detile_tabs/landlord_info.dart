import 'package:flutter/material.dart';
import 'package:cas_house/models/user.dart';

class PersonHeader extends StatelessWidget {
  final User user;
  final String? phone; // jeśli brak – sekcja zniknie
  final String? roleLabel; // np. "Właściciel" / "Najemca" (opcjonalnie)
  final double avatarRadius;

  const PersonHeader({
    super.key,
    required this.user,
    this.phone,
    this.roleLabel,
    this.avatarRadius = 44,
  });

  String get _initial {
    final src = (user.username.isNotEmpty ? user.username : user.email).trim();
    if (src.isEmpty) return "?";
    return src.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final greyBg = Colors.grey.shade300;
    final greyFg = Colors.grey.shade700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar (szare koło z literą)
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: greyBg,
          child: Text(
            _initial,
            style: TextStyle(
              color: greyFg,
              fontSize: avatarRadius, // duża litera
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Nazwa / username duży i gruby
        Text(
          user.username.isNotEmpty
              ? "${user.firstname} ${user.secondname}"
              : user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),

        if (roleLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            roleLabel!,
            style: TextStyle(
              fontSize: 13,
              color:
                  Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Linia jak na screenie
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Divider(height: 1, thickness: 0.8),
        ),

        const SizedBox(height: 16),

        // Telefon
        if (phone != null && phone!.trim().isNotEmpty) ...[
          Text(
            phone!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],

        // Email
        SelectableText(
          user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
