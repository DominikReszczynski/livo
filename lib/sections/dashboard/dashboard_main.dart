import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/sections/dashboard/image_picker.dart';
import 'package:cas_house/sections/dashboard/images_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/dasboard_provider.dart';
import 'package:cas_house/sections/dashboard/multi_image_picker.dart';

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
        const MultiImagePickerExample(),
        const Divider(),
        const SingleImageUploader(),
        RemoteImageList(
          filenames: [
            '42d068d4-6994-4bd1-881a-c18cdb7eb33e.jpg',
            '1743413813108.jpg'
          ],
        )
      ],
    );
  }
}
