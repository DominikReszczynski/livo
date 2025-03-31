import 'package:cas_house/models/product_model.dart';
import 'package:cas_house/sections/defects/components/add_product_popup.dart';
import 'package:cas_house/sections/defects/widgets/product_tile.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ShoppingMain extends StatefulWidget {
  const ShoppingMain({super.key});

  @override
  _ShoppingMainState createState() => _ShoppingMainState();
}

class _ShoppingMainState extends State<ShoppingMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SHOPPING LIST"),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: Icon(MdiIcons.plus),
            iconSize: 30,
          ),
        ],
      ),
      body: Consumer<DefectsProvider>(
        builder: (context, provider, child) {
          return Text('Placeholder');
          // final shoppingList = provider.shoppingList;

          // return ListView.builder(
          //   itemCount: shoppingList.length,
          //   itemBuilder: (context, index) {
          //     return PrductTile(
          //       product: shoppingList[index],
          //       updateIsBuy: () {
          //         provider.toggleIsBuy(index);
          //       },
          //     );
          //   },
          // );
        },
      ),
    );
  }
}
