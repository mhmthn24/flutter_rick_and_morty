import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rick_and_morty/Karakter.dart';
import 'package:http/http.dart';

class ListelemeKarakterler extends StatefulWidget {

  @override
  State<ListelemeKarakterler> createState() => _ListelemeKarakterlerState();
}

class _ListelemeKarakterlerState extends State<ListelemeKarakterler> {
  final String _apiKey = "https://rickandmortyapi.com/api/character/?page=1";
  String? _apiNext;
  String? _apiPrev;

  List<Karakter> _tumKarakterler = [];
  Map<String, dynamic> jsonResponse = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getKarakterler(_apiKey);
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar(){
    return AppBar(
      title: Text("Rick and Morty Characters"),
    );
  }

  Widget _buildBody(){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _tumKarakterler.length,
            itemBuilder: _buildListView
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _apiPrev != null
                    ? (){
                      WidgetsBinding.instance.addPostFrameCallback((_){
                        _getKarakterler(_apiPrev!);
                      });
                    }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: _apiPrev != null
                          ? Colors.white
                          : Colors.black
                    ),
                    SizedBox(width: 8,),
                    Text(
                      "Previous",
                      style: TextStyle(
                          color: _apiPrev != null
                              ? Colors.white
                              : Colors.black
                          ,
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _apiNext != null
                    ? (){
                        WidgetsBinding.instance.addPostFrameCallback((_){
                          _getKarakterler(_apiNext!);
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next",
                      style: TextStyle(
                        color: _apiNext != null
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20
                      ),
                    ),
                    SizedBox(width: 8,),
                    Icon(
                      Icons.arrow_forward,
                      size: 30,
                      color: _apiNext != null
                          ? Colors.white
                          : Colors.black
                      ,
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildListView(BuildContext context, int index){
    return Card(
      child: ListTile(
        title: Text(_tumKarakterler[index].karakter_ad),
        leading: CircleAvatar(backgroundImage: NetworkImage(_tumKarakterler[index].karakter_resim),),
      ),
    );
  }

  void _getKarakterler(String api) async {
    _tumKarakterler = [];
    Uri uri = Uri.parse(api);
    Response response = await get(uri);

    Map<String, dynamic> jsonParsed = jsonDecode(response.body);
    _apiNext = jsonParsed["info"]["next"];
    _apiPrev = jsonParsed["info"]["prev"];
    List<dynamic> results = jsonParsed["results"];

    for(int i = 0; i < results.length; i++){
      Map<String, dynamic> karakter = results[i];
      _tumKarakterler.add(Karakter.fromMap(karakter));
    }
    setState(() {});
  }
}
