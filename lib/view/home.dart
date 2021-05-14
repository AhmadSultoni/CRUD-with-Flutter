import 'package:flutter/material.dart';
import 'package:my_note/view/add.dart';
import 'package:my_note/view/list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Icon(
          Icons.date_range_outlined,
        ),
        centerTitle: true,
        title: Text('My Activity'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SizedBox(height: 50)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(
                builder: (BuildContext context) => AddPage(),
              ))
              .then((value) => setState(() {}));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
