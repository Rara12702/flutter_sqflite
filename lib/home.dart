import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_sqlite/models/item.dart';
import 'package:flutter_sqlite/entryForm.dart';
import 'package:flutter_sqlite/helpers/dbhelper.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Item> itemList;
  @override
  Widget build(BuildContext context) {
    updateListView();

    itemList ??= <Item>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Item - Rara Deninda|2041720110'),
      ),
      body: Column(
        children: [
          Expanded(
            child: createListView(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Tambah Item"),
                onPressed: () async {
                  var item = await navigateToEntryForm(context, null);
                  if (item != null) {
                    int result = await dbHelper.insert(item);
                    if (result > 0) {
                      updateListView();
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Item> navigateToEntryForm(BuildContext context, Item item) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EntryForm(item);
        },
      ),
    );
    return result;
  }

  ListView createListView() {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            isThreeLine: true,
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.people_alt),
            ),
            title: Text(
              itemList[index].name,
              style: textStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Harga : " + itemList[index].price.toString()),
                const SizedBox(
                  height: 5.0,
                ),
                Text("Stok : " + itemList[index].stock.toString()),
                Text("" + itemList[index].kodeBarang.toString()),
              ],
            ),
            // 3.TODO : delete by id
            trailing: GestureDetector(
              child: const Icon(Icons.delete),
              onTap: () async {
                dbHelper.delete(itemList[index].id);
                updateListView();
              },
            ),
            //4. TODO: update by id
            onTap: () async {
              var item = await navigateToEntryForm(context, itemList[index]);
              dbHelper.update(item);
              updateListView();
            },
          ),
        );
      },
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then(
      (database) {
        Future<List<Item>> itemListFuture = dbHelper.getItemList();
        itemListFuture.then(
          (itemList) {
            setState(
              () {
                this.itemList = itemList;
                count = itemList.length;
              },
            );
          },
        );
      },
    );
  }
}
