import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_note/services/BaseURL.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String _lati = "";
  String _longi = "";
  String pathFoto = '';
  PickedFile _image;
  final picker = ImagePicker();

  TextEditingController ctrlNote = new TextEditingController();
  Geolocator geolocator = Geolocator();
  Position currentPosition;

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  showLoaderDialog(BuildContext context, String tulisan) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 20), child: Text(tulisan)),
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

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future getUserLocation() async {
    currentPosition = await locateUser();
    setState(() {
      _lati = currentPosition.latitude.toString();
      _longi = currentPosition.longitude.toString();
    });
  }

  Future ambilFoto() async {
    try {
      final gambar = await picker.getImage(
          source: ImageSource.camera,
          maxHeight: 600.0,
          maxWidth: 400.0,
          imageQuality: 100);
      setState(() {
        _image = gambar;
        pathFoto = _image.path.toString();
      });
    } catch (e) {
      setState(() {
        _image = null;
      });
    }
  }

  Future submitData() async {
    String myUri = BaseURL.myApi + "?action=add_note";

    if (ctrlNote.text.isEmpty) {
      _showAlert('Aktivitas belum diisi !', Colors.red);
      return false;
    }
    if (pathFoto.isEmpty) {
      _showAlert('Foto tidak boleh kosong !', Colors.red);
      return false;
    }

    try {
      getUserLocation();

      showLoaderDialog(context, 'Submitting...');

      var uri = Uri.parse(myUri);
      var request = http.MultipartRequest("POST", uri);
      var myFile = await http.MultipartFile.fromPath("file", _image.path);

      request.fields['note'] = ctrlNote.text;
      request.fields['lati'] = _lati;
      request.fields['longi'] = _longi;
      request.files.add(myFile);

      var respon = await request.send();
      var responStream = await http.Response.fromStream(respon);
      Navigator.pop(context);
      if (responStream.body.isNotEmpty) {
        print(responStream.body);
        _showAlert(json.decode(responStream.body), Colors.green);
      }
      Navigator.pop(context);
    } catch (e) {
      print('Error:' + e.toString());
      Navigator.pop(context);
    }
  }

  _showAlert(String pesan, Color warna) {
    Fluttertoast.showToast(
      msg: pesan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: warna,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Tambah Aktivitas'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Ketuk gambar untuk ambil foto',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        Card(
                          margin: EdgeInsets.all(2),
                          elevation: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width,
                            child: InkWell(
                              onTap: () {
                                ambilFoto();
                              },
                              child: Container(
                                // height: MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      width: MediaQuery.of(context).size.width,
                                      child: _image == null
                                          ? Image.asset(
                                              'assets/images/selfi.jpg',
                                              fit: BoxFit.none,
                                            )
                                          : Image.file(
                                              File(_image.path),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        // Note
                        TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: ctrlNote,
                          onTap: () {},
                          decoration: InputDecoration(
                              hintText: 'Nama Aktivitas',
                              // prefixIcon: Icon(Icons.note_add_outlined),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 12, 20, 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                        ),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Material(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.orange,
                            elevation: 3,
                            child: MaterialButton(
                              onPressed: () async {
                                submitData();
                              },
                              minWidth: MediaQuery.of(context).size.width,
                              height: 45,
                              child: Text(
                                'Simpan',
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
