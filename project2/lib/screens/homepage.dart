import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Товар удален из списка",
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
      backgroundColor: Colors.deepPurple,
    ));
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refreshItems();
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem["name"];
      _quantityController.text = existingItem["quantity"];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) => Container(
        color: Colors.deepPurple[200],
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Название"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(hintText: "Количество"),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (itemKey == null) {
                    _createItem({
                      "name": _nameController.text,
                      "quantity": _quantityController.text
                    });
                  }
                  if (itemKey != null) {
                    _updateItem(itemKey, {
                      'name': _nameController.text.trim(),
                      'quantity': _quantityController.text.trim()
                    });
                  }

                  _nameController.text = '';
                  _quantityController.text = "";

                  Navigator.of(context).pop();
                },
                child: Text('Сохранить'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: const Text(
          "Корзина",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.deepPurple,
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(
                  currentItem["name"],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                subtitle: Text(
                  currentItem['quantity'].toString(),
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showForm(context, currentItem['key']),
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteItem(currentItem['key']),
                        icon: const Icon(Icons.delete)),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
