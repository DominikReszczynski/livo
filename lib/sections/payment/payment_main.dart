import 'package:cas_house/models/product_model.dart';
import 'package:cas_house/providers/payment_provider.dart';
import 'package:cas_house/sections/defects/components/add_product_popup.dart';
import 'package:cas_house/sections/defects/widgets/product_tile.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PaymentMain extends StatefulWidget {
  const PaymentMain({super.key});

  @override
  _PaymentMainState createState() => _PaymentMainState();
}

class _PaymentMainState extends State<PaymentMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment List"),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: Icon(MdiIcons.plus),
            iconSize: 30,
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
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
          return Text('placeholder');
        },
      ),
    );
  }
}
