import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = List<Item>.empty(growable: true);

  HomePage() {
    // items.add(Item(done: false, title: "Banana"));
    // items.add(Item(done: true, title: "Abacate"));
    // items.add(Item(done: false, title: "Laranja"));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  _HomePageState() {
    load();
  }

  void addItem() {
    if (newTaskController.text.isEmpty) return;

    setState(() {
      widget.items.add(new Item(
        done: false,
        title: newTaskController.text,
      ));
      newTaskController.clear();
    });

    save();
  }

  void removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
    });

    save();
  }

  Future load() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString("items");
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      var items = decoded.map((itemJson) => Item.fromJson(itemJson));

      setState(() {
        widget.items.addAll(items);
      });
    }
  }

  Future save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString("items", jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return Dismissible(
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.7),
            ),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.setIsDone(value);
                });

                save();
              },
            ),
            onDismissed: (direction) {
              removeItem(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
