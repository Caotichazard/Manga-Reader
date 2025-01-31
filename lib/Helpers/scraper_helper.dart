



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
    for(int i=0;i<capsPorNumero.length;i++){
      var prevUrl;
      var nextUrl;
      //url prevCap
      if(i>0){
        Element nextCap = capsPorNumero[i-1];
        final nextCapCont = nextCap.getElementsByTagName('a');
        nextUrl= nextCapCont[0].attributes['href'];
      }else{
        nextUrl = 'null';
      }

      if(i<capsPorNumero.length-1){
        Element prevCap = capsPorNumero[i+1];
        final prevCapCont = prevCap.getElementsByTagName('a');
        prevUrl= prevCapCont[0].attributes['href'];
      }else{
        prevUrl = 'null';
      }

      
      Element thisCap= capsPorNumero[i];
      final caps = thisCap.getElementsByTagName('a');
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
        capitulo = Capitulo(null,manga.title,numero,url,0,1,nextUrl,prevUrl);
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
    var titulo;
    var capaUrl;
    var numero;
    var capRecenteUrl;
    final document = parse(utf8.decode(response.bodyBytes));
    final mangaInfo = document.getElementsByClassName('tamanho-bloco-perfil');
    for(Element infos in mangaInfo){
      final infoCont = infos.getElementsByClassName('row');
      //get titulo
      Element tituloCont = infoCont[0];
      final tituloH = tituloCont.getElementsByTagName('h2');
      Element tituloCont2 = tituloH[0];
      titulo = '['+tituloCont2.text+']';
      //print(titulo);

      //get capa
      
      Element capaCont = infoCont[2];
      final capaImg = capaCont.getElementsByTagName('img');
      Element capaCont2 = capaImg[0];
      capaUrl = capaCont2.attributes['src'];
      
      //get caprecente
      final capsPorNumero = document.getElementsByClassName('row lancamento-linha');
      final caps = capsPorNumero.last.getElementsByTagName('a');
      Element info = caps[0];
      numero = info.text.split(' ')[1];
      capRecenteUrl = info.attributes['href'];
      
      
      
      
    }

    final mangaDetails = document.getElementsByClassName('manga-perfil');

    //get author

    Element authorInfo = mangaDetails[2];
    var author = authorInfo.text; 

    //get genres

    Element genresInfo = mangaDetails[1];
    var genres = genresInfo.text;

    //get status
    Element statusInfo = mangaDetails[4];
    var status = statusInfo.text;

    manga = Manga(null,source,titulo,capaUrl,numero,capRecenteUrl,author,genres,status);
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
