//import 'package:hello_world/paginas.dart';



class Capitulo{
  String numero;
  String url;
  //List<Paginas> paginas;
  int read;
  int id;
  int newChap;
  
  Capitulo(this.id,this.numero,this.url,this.read,this.newChap);

  Map<String, dynamic> toMap(){
      var map = <String, dynamic>{
        'id': id,
        'url': url,
        'read': read,
        'numero': numero,
        'newChap': newChap,
        
      };
      return map;
    }

    Capitulo.fromMap(Map<String, dynamic> map){
      id = map['id'];
      url = map['url'];
      numero = map['numero'];
      read = map['read']; 
      newChap = map['newChap'];     
    }
}