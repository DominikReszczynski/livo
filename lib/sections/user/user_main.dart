import 'package:cas_house/providers/user_provider.dart';
import 'package:cas_house/sections/login.dart';
import 'package:cas_house/sections/user/edit_user_screen.dart';
import 'package:cas_house/sections/user/user_section_header.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class UserSectionMain extends StatefulWidget {
  const UserSectionMain({super.key});

  @override
  State<UserSectionMain> createState() => _UserSectionMainState();
}

class _UserSectionMainState extends State<UserSectionMain> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      final user = userProvider.user;
      final email = user?.email ?? '';
      final username = user?.username ?? '';
      final phone = user?.phone ?? '';

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),

          // Header dostaje dane Z PROVIDERA (nie z globala)
          UserSectionHeader(
            username: username,
            email: email,
            phone: phone,
          ),

          const SizedBox(height: 16),

          // KARTA: Dane i akcje
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    username.isNotEmpty ? username : email,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      if (email.isNotEmpty) email,
                      if (phone.isNotEmpty) phone,
                    ].join('\n'),
                  ),
                  trailing: IconButton(
                    tooltip: 'Kopiuj e-mail',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: email.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: email));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Adres e-mail skopiowany')),
                            );
                          },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edytuj dane użytkownika'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditUserScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Wylogowanie
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Wyloguj się'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              // wyczyść stan aplikacji
              context.read<UserProvider>().logout();
              UserServices().logout();
              // jeśli trzymasz gdzieś global, warto go wyzerować w logout providera
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      );
    });
  }
}
