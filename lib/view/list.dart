import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_note/services/BaseURL.dart';
import 'package:http/http.dart' as http;
import 'package:my_note/view/detail.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool loading = false;
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  Future tampilData() async {
    setState(() {
      loading = true;
    });
    try {
      String myUri = BaseURL.myApi + "?action=get_note";
      final respon = await http.post(myUri, body: {"id": ""});
      var dataku = json.decode(respon.body);
      if (dataku[0]['ID'] != '-') {
        setState(() {
          loading = false;
        });
        print('done');
        return json.decode(respon.body);
      } else {
        loading = false;
        print('data kosong');
        return null;
      }
    } catch (e) {
      print(e.toString());
      loading = false;
      print('load data gagal');
      return null;
    }
  }

  showLoaderDialog(BuildContext context, String tulisan) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 15), child: Text(tulisan)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    tampilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: loading == true
          ? Center(
              //child: CircularProgressIndicator(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CircularProgressIndicator(),
                  SvgPicture.asset(
                    'assets/icons/007-file.svg',
                    width: 150,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('No data to display',
                      style: TextStyle(color: Colors.red, fontSize: 15)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: tampilData,
              key: _refresh,
              child: FutureBuilder(
                future: this.tampilData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return ItemList(
                    list: snapshot.data,
                  );
                },
              ),
            ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return Column(
          children: [
            ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      // DetailHazard(list: list, index: i)),
                      DetailPage(
                    list: list,
                    index: i,
                  ),
                ),
              ),
              leading: list[i]['FOTO'] == ''
                  ? CircularProgressIndicator()
                  : Image.network(
                      BaseURL.fotoUrl + list[i]['FOTO'],
                      fit: BoxFit.cover,
                    ),
              title: Text(
                list[i]['NOTE'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(list[i]['LOG_DATE']),
              trailing: Icon(Icons.chevron_right),
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
