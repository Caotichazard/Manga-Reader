import 'package:flutter/material.dart';
import 'package:socorro/Screens/mangaCollection.dart';
import 'package:socorro/Screens/mangaPage.dart';
import 'package:socorro/Screens/mangaReader.dart';
import 'package:socorro/Models/manga.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;
    final title = settings.name;
    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => MangaCollection(title: 'Mangas'));
      case '/manga':
        if(args is Manga){
          return MaterialPageRoute(
            builder: (_) => MangaPage(title: 'Detalhes do manga',
              data:args,
            ),
            );
        }
        return _errorRoute();

      case '/manga/reader':
        if(args is String){
          return MaterialPageRoute(
            builder: (_) => MangaReader(title: title,
              data:args,
            ),
            );
        }
        return _errorRoute();
        
      default:
        return _errorRoute(); 
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}