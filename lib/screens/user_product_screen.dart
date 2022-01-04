import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/app_drawer.dart';
import '../provider/products_provider.dart';
import '../widget/user_product.dart';
import './edite_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeNAme = '/user-product-screen';
  Future<void> _refresfProducts(BuildContext context) async {
    await Provider.of<ProducstProvider>(context, listen: false)
        .feachAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your producr'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditeProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refresfProducts(context),
        builder: (cxt, snapShot) =>
            snapShot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refresfProducts(context),
                    child: Consumer<ProducstProvider>(
                      builder: (cxt, productData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProduct(
                                id: productData.items[i].id,
                                title: productData.items[i].title,
                                imgurl: productData.items[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
