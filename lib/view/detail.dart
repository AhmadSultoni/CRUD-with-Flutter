import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_note/services/BaseURL.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailPage extends StatefulWidget {
  final List list;
  final int index;

  DetailPage({this.list, this.index});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextStyle styleku = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black87);

  String sId = '';
  String sNote = '';
  String sFoto = '';
  String sLati = '';
  String sLongi = '';
  String sLogDate = '';

  LatLng myLokasi;
  final Map<String, Marker> _marker = {};

  @override
  void initState() {
    sId = widget.list[widget.index]['ID'];
    sNote = widget.list[widget.index]['NOTE'];
    sFoto = widget.list[widget.index]['FOTO'];
    sLati = widget.list[widget.index]['LATI'];
    sLongi = widget.list[widget.index]['LONGI'];
    sLogDate = widget.list[widget.index]['LOG_DATE'];
    myLokasi = LatLng(double.parse(sLati), double.parse(sLongi));
    final myMarker = Marker(
        markerId: MarkerId("My Position"),
        position: myLokasi,
        infoWindow:
            InfoWindow(title: "Lokasi", snippet: "Aktivitas: " + sNote));
    _marker['Current Location'] = myMarker;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topContent = Stack(
      children: [
        Container(
          // padding: EdgeInsets.only(left: 10),
          height: MediaQuery.of(context).size.height * 0.5,
          // width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            imageUrl: BaseURL.fotoUrl + sFoto,
            //height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fadeInCurve: Curves.bounceIn,
            // fadeOutCurve: Curves.fastOutSlowIn,
            fadeInDuration: const Duration(milliseconds: 2000),
            //fadeOutDuration: const Duration(milliseconds: 3000),
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        )
      ],
    );

    final isiList = Column(
      children: [
        // Divider(),
        ListTile(
          leading: Icon(Icons.note_outlined),
          title: Text(
            'Aktivitas : ' + sNote,
            style: styleku,
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.alarm),
          title: Text(
            'Create Date : ' + sLogDate,
            style: styleku,
          ),
        ),
        Divider(),
      ],
    );

    final isiMap = SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: GoogleMap(
        // onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: myLokasi == null ? CircularProgressIndicator() : myLokasi,
          // target: LatLng(-6.2446139, 106.6466305),
          zoom: 11.0,
        ),
        markers: _marker.values.toSet(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detail Data'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Card(
          child: Column(
            children: [
              topContent,
              isiList,
              SizedBox(
                child: Text("Lokasi Maps :"),
              ),
              isiMap,
            ],
          ),
        ),
      ),
    );
  }
}
