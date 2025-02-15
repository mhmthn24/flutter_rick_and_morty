class Karakter{
  int karakter_id;
  String karakter_ad;
  String karakter_durum;
  String karakter_tur;
  String karakter_cinsiyet;
  String karakter_resim;

  Karakter.fromMap(Map<String, dynamic> karakterMap):
    karakter_id = karakterMap["id"] ?? 99999,
    karakter_ad = karakterMap["name"] ?? "-",
    karakter_durum = karakterMap["status"] ??  "-",
    karakter_cinsiyet = karakterMap["gender"] ?? "-",
    karakter_resim = karakterMap["image"] ?? "-",
    karakter_tur = karakterMap["species"] ?? "-";

}

/*
"results": [
    {
      "id": 361,
      "name": "Toxic Rick",
      "status": "Dead",
      "species": "Humanoid",
      "type": "Rick's Toxic Side",
      "gender": "Male",
      "origin": {
        "name": "Alien Spa",
        "url": "https://rickandmortyapi.com/api/location/64"
      },
      "location": {
        "name": "Earth",
        "url": "https://rickandmortyapi.com/api/location/20"
      },
      "image": "https://rickandmortyapi.com/api/character/avatar/361.jpeg",
      "episode": [
        "https://rickandmortyapi.com/api/episode/27"
      ],
      "url": "https://rickandmortyapi.com/api/character/361",
      "created": "2018-01-10T18:20:41.703Z"
    },
    // ...
  ]
 */