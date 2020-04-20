



import 'package:socorro/Helpers/db_helper.dart';
import 'package:socorro/Models/manga.dart';

import 'package:socorro/Models/capitulo.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart';

import 'package:html/parser.dart';
import 'package:socorro/Models/pagina.dart';
import 'dart:convert';

class SCHelper{
  Client _client;

  DBHelper _dbHelper = DBHelper();

  SCHelper(){
      this._client = Client();
  }

  /*void getTodosCapitulos(Manga manga) async{
    List<Capitulo> capitulos = [];
    final response =  await _client.get(manga.url);
    
    final document = parse(utf8.decode(response.bodyBytes));
    final capsPorNumero = document.getElementsByClassName('row lancamento-linha');
    for(Element capPorNumero in capsPorNumero){
      final caps = capPorNumero.getElementsByTagName('a');
      Element info = caps[0];
      final numero = info.text.split(' ')[1];
      //print(numero);
      final url = info.attributes['href'];
      final capitulo = Capitulo(null,numero,url,0,0);
      capitulos.add(capitulo);
      
    }

    for(Capitulo cap in capitulos.reversed){
      _dbHelper.saveChap(cap, manga);
    }
    
  }*/

  void updateCapsNovos(Manga manga) async{
    List<Capitulo> capitulos = [];
    List<Capitulo> capOld = await _dbHelper.getChaps(manga.title);

    final response =  await _client.get(manga.url);
    Capitulo capitulo;
    final document = parse(utf8.decode(response.bodyBytes));
    final capsPorNumero = document.getElementsByClassName('row lancamento-linha');
    for(Element capPorNumero in capsPorNumero){
      final caps = capPorNumero.getElementsByTagName('a');
      Element info = caps[0];
      final numero = info.text.split(' ')[1];
      //print(numero);
      final url = info.attributes['href'];
      var novo = true;
      for(Capitulo cap in capOld){
        if(cap.numero == numero){
          novo = false;
          capitulo = cap;
          capitulo.newChap = 0;
          _dbHelper.updateChap(capitulo, manga.title);
        }
      }
      if(novo){
        capitulo = Capitulo(null,numero,url,0,1);
        capitulos.add(capitulo);
      }
      
      
    }

    for(Capitulo cap in capitulos.reversed){
      _dbHelper.saveChap(cap, manga);
    }

    
    
  }

  Future<Manga> getMangaInfo(source) async{
    final response =  await _client.get(source);
    var manga;
    
    final document = parse(utf8.decode(response.bodyBytes));
    final mangaInfo = document.getElementsByClassName('tamanho-bloco-perfil');
    for(Element infos in mangaInfo){
      final infoCont = infos.getElementsByClassName('row');
      //get titulo
      Element tituloCont = infoCont[0];
      final tituloH = tituloCont.getElementsByTagName('h2');
      Element tituloCont2 = tituloH[0];
      String titulo = '['+tituloCont2.text+']';
      //print(titulo);

      //get capa
      
      Element capaCont = infoCont[2];
      final capaImg = capaCont.getElementsByTagName('img');
      Element capaCont2 = capaImg[0];
      final capaUrl = capaCont2.attributes['src'];
      
      //get caprecente
      final capsPorNumero = document.getElementsByClassName('row lancamento-linha');
      final caps = capsPorNumero[0].getElementsByTagName('a');
      Element info = caps[0];
      final numero = info.text.split(' ')[1];
      final capRecenteUrl = info.attributes['href'];
      
      manga = Manga(null,source,titulo,capaUrl,numero,capRecenteUrl);
      
      
    }
    return manga;
    //logica de pegar titulo imagem descrição e etc de um manga
  }


  Future<List<Pagina>> getPaginasCapitulo(source) async{
       
        List<Pagina> todasPags = [];
        var pagina;
        
        final response =  await _client.get(source);
        
        final document = parse(response.body);
        
        final pagsPorNumero = document.getElementsByClassName('img-manga');
        
        print(pagsPorNumero.length);
        
        var pagUrl = pagsPorNumero[0].attributes['src'];
        print(pagUrl);
        for( Element pag in pagsPorNumero){
          
            var pagUrl = pag.attributes['src'];
            print(pagUrl);
            pagina = Pagina(pagUrl);
            todasPags.add(pagina);
          
        }

        return todasPags;
  }
}
