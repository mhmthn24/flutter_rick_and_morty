import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rick_and_morty/Detay_Karakter.dart';
import 'package:flutter_rick_and_morty/Karakter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> favorilerShared = [];
  
  bool favoriGoster = false;

  @override
  void initState() {
    super.initState();
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _apiNext = _apiKey; // İlk API cagrisini baslatalim
      do {
        _apiNext = await _getKarakterler(_apiNext!); // Sonraki sayfayi guncelleyelim
      } while (_apiNext != null); // nextPage null olana kadar devam edelim
    });
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _favorileriYukle().then((value) async {
        _apiNext = _apiKey; // İlk API cagrisini baslatalim
        do {
          _apiNext = await _getKarakterler(_apiNext!); // Sonraki sayfayi guncelleyelim
        } while (_apiNext != null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        floatingActionButton: _buildFloatingButton(),
        body: Stack(
          children: [
            Opacity(
              opacity: 0.2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/arkaplan.webp"),
                    fit: BoxFit.cover
                  )
                ),
              ),
            ),
            _buildBody()
          ],
        ),
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
          if (!favoriGoster)
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
  
  Widget _buildFloatingButton(){
    return FloatingActionButton(
      onPressed: (){
        setState(() {
          favoriGoster = !favoriGoster;
        });
      },
      child: favoriGoster 
          ? Icon(Icons.list)
          : Icon(Icons.favorite),
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
                    : !favoriGoster
                      ? _tumKarakterler.length
                      : _favoriKarakterler.length,
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
    }else if(favoriGoster){
      listeKarakter = _favoriKarakterler;
    }else{
      listeKarakter = _tumKarakterler;
    }

    return Card(
      color: Color(0xFF111DAB).withOpacity(0.4),
      child: ListTile(
        title: Text(
          listeKarakter[index].karakter_ad,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Image.network(
          listeKarakter[index].karakter_resim,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return CircleAvatar(backgroundImage: NetworkImage(listeKarakter![index].karakter_resim));
            }
            return CircularProgressIndicator(); // ✅ Yüklenene kadar animasyon göster
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error); // ❌ Hata olursa ikon göster
          },
        ),
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
        onTap: (){
          if(listeKarakter != null){
            _gitKarakterDetay(context, listeKarakter[index]);
          }
        },
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

  void _favoriEkleCikar(Karakter karakter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (favorilerShared.contains(karakter.karakter_id.toString())){
      favorilerShared.remove(karakter.karakter_id.toString());
      _favoriKarakterler.remove(karakter);
    }else{
      favorilerShared.add(karakter.karakter_id.toString());
      _favoriKarakterler.add(karakter);
    }

    await prefs.setStringList("favoriler", favorilerShared);
    setState(() {});
  }

  Future<void> _favorileriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriler = await prefs.getStringList("favoriler");
    if(favoriler != null){
      for(String ulkeKodu in favoriler){
        favorilerShared.add(ulkeKodu);
      }
    }
  }

  Future<String?> _getKarakterler(String api) async {
    Uri uri = Uri.parse(api);
    Response response = await get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonParsed = jsonDecode(response.body);

      _apiNext = jsonParsed["info"]["next"];
      List<dynamic> results = jsonParsed["results"];

      for (var karakter in results) {
        Karakter kar = Karakter.fromMap(karakter);
        _tumKarakterler.add(kar);
        if(favorilerShared.contains(kar.karakter_id.toString())){
          _favoriKarakterler.add(kar);
        }
      }

      setState(() {}); // UI güncellemesi

      return _apiNext; // ✅ Sonraki sayfa URL’sini döndür
    } else {
      return null; // ❌ Eğer hata alırsa, null döndür ve döngüyü bitir
    }
  }

  void _gitKarakterDetay(BuildContext context, Karakter karakter){
    MaterialPageRoute gidilecekSayfaYolu = MaterialPageRoute(builder: (context){
      return DetayKarakter(karakter);
    });
    Navigator.push(context, gidilecekSayfaYolu);
  }


}
