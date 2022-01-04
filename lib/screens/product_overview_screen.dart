import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/product_grid.dart';
import '../widget/badge.dart';
import '../provider/cart.dart';
import './cart_screen.dart';
import '../widget/app_drawer.dart';
import '../provider/products_provider.dart';

enum FilterOptions {
  Favorite,
  All,
}

class ProductOverview extends StatefulWidget {
  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  @override
  void initState() {
    setState(() {
      _loading = true;
    });
    Provider.of<ProducstProvider>(context, listen: false)
        .feachAndSetProducts()
        .then(
          (_) => setState(
            () {
              _loading = false;
            },
          ),
        );
    super.initState();
  }

  var _showFavoriteItems = false;
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop App',
        ),
        actions: [
          PopupMenuButton(
            onSelected: (
              FilterOptions selectedValue,
            ) {
              setState(() {
                if (selectedValue == FilterOptions.Favorite) {
                  _showFavoriteItems = true;
                } else {
                  _showFavoriteItems = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  'Only Favorites',
                ),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text(
                  'Show All',
                ),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.productCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(
              showFavoriteItem: _showFavoriteItems,
            ),
    );
  }
}
