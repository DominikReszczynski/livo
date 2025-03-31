import 'dart:ffi';

import 'package:cas_house/providers/dasboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../widgets/loading.dart';
import '../../widgets/typewrite_text.dart';

class AiField extends StatefulWidget {
  final DashboardProvider dashboardProvider;
  const AiField({super.key, required this.dashboardProvider});

  @override
  State<AiField> createState() => _AiFieldState();
}

class _AiFieldState extends State<AiField> {
  double screenWidth = 0.0;
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: screenWidth - 20,
          decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              border: const Border(bottom: BorderSide(color: Colors.black))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AI tip",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(MdiIcons.brain)
              ],
            ),
          ),
        ),
        Container(
          width: screenWidth - 20,
          decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )),
          padding: const EdgeInsets.only(top: 5, left: 5, bottom: 10, right: 5),
          child: Column(
            children: [
              widget.dashboardProvider.loadingChat
                  ? const LoadingWidget()
                  : widget.dashboardProvider.chatText != ""
                      ? TypewriterText(
                          text: widget.dashboardProvider.chatText,
                          duration: const Duration(milliseconds: 2000),
                          textStyle: const TextStyle(fontSize: 15),
                        )
                      : const SizedBox(),
              widget.dashboardProvider.loadingChat
                  ? const SizedBox()
                  : widget.dashboardProvider.chatText == ""
                      ? TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.amber),
                          ),
                          onPressed: () {
                            widget.dashboardProvider.chat();
                          },
                          child: const Text("Press to generate"),
                        )
                      : const SizedBox()
            ],
          ),
        )
      ],
    );
  }
}
// 
