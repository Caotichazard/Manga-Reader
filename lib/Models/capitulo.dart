//import 'package:hello_world/paginas.dart';



class Capitulo{
  String manga;
  String numero;
  String url;
  //List<Paginas> paginas;
  int read;
  int id;
  int newChap;
  String nextUrl;
  String prevUrl;
  
  Capitulo(this.id,this.manga,this.numero,this.url,this.read,this.newChap,this.nextUrl,this.prevUrl);

  Map<String, dynamic> toMap(){
      var map = <String, dynamic>{
        'id': id,
        'url': url,
        'read': read,
        'numero': numero,
        'newChap': newChap,
        'nextUrl': nextUrl,
        'prevUrl': prevUrl,
        'manga': manga
        
      };
      return map;
    }

    Capitulo.fromMap(Map<String, dynamic> map){
      id = map['id'];
      url = map['url'];
      numero = map['numero'];
      read = map['read']; 
      newChap = map['newChap'];
      nextUrl = map['nextUrl'];
      prevUrl = map['prevUrl'];   
      manga = map['manga'];  
    }
}