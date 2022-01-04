import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';
import '../provider/products_provider.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavoriteItem;
  ProductGrid({this.showFavoriteItem});
  @override

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProducstProvider>(context);
    final produsts = showFavoriteItem?productsData.favorotItems: productsData.items;
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      itemBuilder: (contex, i) => ChangeNotifierProvider.value(
        value: produsts[i],
        child: ProductItem(),
      ),
      itemCount: produsts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 3 / 2,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
