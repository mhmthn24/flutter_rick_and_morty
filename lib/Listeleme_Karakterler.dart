import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rick_and_morty/Karakter.dart';
import 'package:http/http.dart';

class ListelemeKarakterler extends StatefulWidget {

  @override
  State<ListelemeKarakterler> createState() => _ListelemeKarakterlerState();
}

class _ListelemeKarakterlerState extends State<ListelemeKarakterler> {

  // ** API degiskenleri **
  final String _apiKey = "https://rickandmortyapi.com/api/character/?page=2";

  // butun sayfalardan bilgileri alırken sonraki sayfa kontrolunde kullanilir
  String? _apiNext;
  List<Karakter> _tumKarakterler = [];
  Map<String, dynamic> jsonResponse = {};

  // ** arama degiskenleri **
  bool aramaAktif = false;
  // arama aktif olunca otomatik klavyeyi acmak icin focusNode olusturalim
  final FocusNode _focusNode = FocusNode();
  List<Karakter> arananKarakterler = [];
  TextEditingController _controllerArama = TextEditingController();

  List<Karakter> _favoriKarakterler = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _apiNext = _apiKey; // İlk API cagrisini baslatalim
      do {
        _apiNext = await _getKarakterler(_apiNext!); // Sonraki sayfayi guncelleyelim
      } while (_apiNext != null); // nextPage null olana kadar devam edelim
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          if(!aramaAktif)
            Text(
              "Rick and Morty Characters",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
              ),
            )
          else
            Expanded(
              child: TextField(
                controller: _controllerArama,
                focusNode: _focusNode,
                onChanged: _aramaYap,
              ),
            ),
          IconButton(
              onPressed: (){
                setState(() {
                  aramaAktif = !aramaAktif;
                  if (aramaAktif){
                    Future.delayed(Duration(milliseconds: 100), (){
                      _focusNode.requestFocus();
                    });
                  }else{
                    arananKarakterler.clear();
                    _controllerArama.clear();
                    _focusNode.unfocus();
                  }
                });
              },
              icon: aramaAktif
                  ? Icon(Icons.cancel_outlined, size: 30,)
                  : Icon(Icons.search, size: 30,)
          )
        ],
      ),
    );
  }

  Widget _buildBody(){
    return _tumKarakterler.length >= 400
        ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: aramaAktif
                    ? arananKarakterler.length
                    : _tumKarakterler.length,
                itemBuilder: _buildListView
              ),
            ),
          ],
        )
        : Center(child: CircularProgressIndicator());
  }

  Widget _buildListView(BuildContext context, int index){
    List<Karakter>? listeKarakter;
    if (aramaAktif){
     listeKarakter = arananKarakterler;
    }else{
      listeKarakter = _tumKarakterler;
    }

    return Card(
      color: Color(0xFF111DAB).withOpacity(0.4),
      child: ListTile(
        title: Text(listeKarakter[index].karakter_ad, style: TextStyle(color: Colors.white),),
        leading: CircleAvatar(backgroundImage: NetworkImage(listeKarakter[index].karakter_resim),),
        trailing: IconButton(
          onPressed: (){
            if (listeKarakter != null){
              _favoriEkleCikar(listeKarakter[index]);
            }
          },
          icon: Icon(
            _favoriKarakterler.contains(listeKarakter[index])
                ? Icons.favorite
                : Icons.favorite_border,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _aramaYap(String query){
    setState(() {
      String? aranacakKelime = query.trim().toLowerCase();

      if(aranacakKelime.isNotEmpty){
        arananKarakterler = _tumKarakterler
            .where(
                (karakter) => karakter
                .karakter_ad
                .toLowerCase()
                .contains(aranacakKelime))
            .toList();
      }else{
        arananKarakterler = [];
      }
    });
  }

  void _favoriEkleCikar(Karakter karakter){
    setState(() {
      if (_favoriKarakterler.contains(karakter)){
        _favoriKarakterler.remove(karakter);
      }else{
        _favoriKarakterler.add(karakter);
      }
    });
  }

  Future<String?> _getKarakterler(String api) async {
    Uri uri = Uri.parse(api);
    Response response = await get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonParsed = jsonDecode(response.body);

      _apiNext = jsonParsed["info"]["next"];
      List<dynamic> results = jsonParsed["results"];

      for (var karakter in results) {
        _tumKarakterler.add(Karakter.fromMap(karakter));
      }

      setState(() {}); // UI güncellemesi

      return _apiNext; // ✅ Sonraki sayfa URL’sini döndür
    } else {
      return null; // ❌ Eğer hata alırsa, null döndür ve döngüyü bitir
    }
  }

}
