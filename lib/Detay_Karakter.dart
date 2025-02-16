import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rick_and_morty/Karakter.dart';

class DetayKarakter extends StatelessWidget {
  
  Karakter karakter;
  
  DetayKarakter(this.karakter);
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Opacity(
                opacity: 0.2,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/arkaplan.webp",),
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),
              _buildBody(),
            ],
          ),
        ) 
    );
  }
  
  AppBar _buildAppBar(){
    return AppBar(
      title: Text(karakter.karakter_ad),
      backgroundColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildBody(){
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(karakter.karakter_resim),
              radius: 100,
            ),
            _buildDetaySatir("Status", karakter.karakter_durum),
            _buildDetaySatir("Species", karakter.karakter_tur),
            _buildDetaySatir("Gender", karakter.karakter_tur),
          ],
        ),
      ),
    );
  }

  Widget _buildDetaySatir(String baslik, String detayBilgi){
    return Card(
      color: Color(0xFF111DAB).withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              baslik,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            Text(
              detayBilgi,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),)
          ],
        ),
      ),
    );
  }
}
