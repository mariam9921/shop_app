import 'package:flutter/material.dart';
import 'package:shop_app/screens/edite_product_screen.dart';
import 'package:provider/provider.dart';
import '../provider/products_provider.dart';

class UserProduct extends StatelessWidget {
  final String title;
  final String imgurl;
  final String id;
  UserProduct({
    this.id,
    this.title,
    this.imgurl,
  });
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          imgurl,
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditeProductScreen.routeName,
                    arguments: id,
                  );
                }),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await Provider.of<ProducstProvider>(context, listen: false)
                      .deletProduct(id);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deleting failed!!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
