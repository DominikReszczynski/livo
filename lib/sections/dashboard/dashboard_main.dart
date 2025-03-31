import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/sections/dashboard/ai_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/dasboard_provider.dart';

class HomeSectionMain extends StatefulWidget {
  const HomeSectionMain({super.key});

  @override
  State<HomeSectionMain> createState() => _HomeSectionMainState();
}

class _HomeSectionMainState extends State<HomeSectionMain> {
  late DashboardProvider dashboardProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dashboardProvider = Provider.of<DashboardProvider>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10, top: 20),
          child: AutoSizeText(
            "Hi, Dominik",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
        const Divider(),
        AiField(dashboardProvider: dashboardProvider)
      ],
    );
  }
}
