
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



import 'package:socorro/Helpers/scraper_helper.dart';

import 'package:socorro/Helpers/db_helper.dart';
import 'package:socorro/Models/capitulo.dart';
import 'package:socorro/Models/pagina.dart';
import 'package:socorro/Models/manga.dart';



class MangaReader extends StatefulWidget {

  final Capitulo data;
  final String title;

  MangaReader({
    Key key,
    this.title,
    @required this.data,
  }) : super(key: key);
 

  

  
  

  @override
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  

  var dbHelper;
  var scrapHelper;
  Future<List<Pagina>> paginas;
  Capitulo current;
  var currentPage =0;
  var nextPage = 0;
  var maxPage;

  Manga manga;

  var backgroundState = false;
  var bgColor = Colors.black;

  var readState = false;
  var readMode = 'manga';
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    scrapHelper = SCHelper();
    current  = widget.data;
    
    refreshList();
  }

  refreshList(){
    
    setState(() {
      paginas = scrapHelper.getPaginasCapitulo(current.url);
    });
  }

  changeChap(url) async {
      if(url == 'null'){
        return;
      }
     
      
      Capitulo chap = await dbHelper.getSingleChap(current.manga,url);
      current = chap;
      manga = await dbHelper.getSingleManga(current.manga);
      print(manga.title);
      print(manga.lastChapNum);
      manga.lastChapNum = current.numero;
      manga.lastChapUrl = current.url;
      print(manga.lastChapNum);
      await dbHelper.updateManga(manga);
      Capitulo capituloUp = current;
      capituloUp.read = 1;
      capituloUp.newChap = 0;
      await dbHelper.updateChap(capituloUp,current.manga);
      setState(() {
        paginas = scrapHelper.getPaginasCapitulo(current.url);
        currentPage=0;
      });
  }
  
    
  
  

  

 SingleChildScrollView mangaView(List<Pagina> paginas) {
    return SingleChildScrollView(
      
        
        child: IndexedStack(
        
        alignment: Alignment.center,
        index: currentPage,
        
        children: paginas
              .map(
                (pagina) => Card(
                  //alignment: Alignment.center,
                  margin: EdgeInsets.all(10.0),
                  
                  //width: MediaQuery.of(context).size.width,
                  
                  
                  child: InkWell(
                    child:
                    Center(child: CachedNetworkImage(
                    imageUrl: pagina.url,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(child:CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  ),
                  onTap: (){},
                  onTapDown: (TapDownDetails details){
                    
                    setState(() {
                      maxPage = paginas.length;
                      var x = details.globalPosition.dx;
                      if(x > MediaQuery.of(context).size.width/2){
                        if(currentPage < maxPage-1){
                          currentPage++;
                        }else{
                          print('fim do capitulo');
                        }
                      }
                      else{
                        if(currentPage > 0){
                          currentPage--;
                        }else{
                          print('fim do capitulo');
                        }
                      }
                    });
                      
                  }
                  
                  ),
                  
                 
                
                )
                
                ).toList()
          ,
          
        )
    );
        
      
  }

  ListView webtoonView(List<Pagina> paginas) {
    return ListView(
        
        
        
        children: paginas
              .map(
                (pagina) => Container(
                  //alignment: Alignment.center,
                  
                  
                  //width: MediaQuery.of(context).size.width,
                  
                  
                  child: InkWell(
                    child:
                    Center(child: CachedNetworkImage(
                    imageUrl: pagina.url,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(child:CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  ),
                  onTap: (){},
                  onTapDown: (TapDownDetails details){
                    
                    setState(() {
                      maxPage = paginas.length;
                      var x = details.globalPosition.dx;
                      if(x > MediaQuery.of(context).size.width/2){
                        if(currentPage < maxPage-1){
                          currentPage++;
                        }else{
                          print('fim do capitulo');
                        }
                      }
                      else{
                        if(currentPage > 0){
                          currentPage--;
                        }else{
                          print('fim do capitulo');
                        }
                      }
                    });
                      
                  }
                  
                  ),
                  
                 
                
                )
                
                ).toList()
          ,
          
        )
    ;
        
      
  }

  list() {
    return Expanded(
      
      child: FutureBuilder(
        future: paginas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(readMode == 'manga'){
              return Center(child:mangaView(snapshot.data));
            }else{
              return webtoonView(snapshot.data);
            }
          }
          if (snapshot.data == null ) {
            return Center(
              child: CircularProgressIndicator(),
              );
          }          
        },
      ),
    );
  }
  
  optionsForm(){
      showDialog(context: context,
              builder: (BuildContext context){
                return AlertDialog(
                    content: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Positioned(
                          right: -40.0,
                          top: -40.0,
                          child: InkResponse(
                            onTap: () {
                              
                              Navigator.of(context).pop();
                            },
                            child: CircleAvatar(
                              child: Icon(Icons.close),
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                        Row(children:[Text('Mode: '),
                            Icon(Icons.view_column),
                            Switch(
                          value: readState,
                          onChanged: (bool s){
                            setState(() {
                              readState =s;
                              print(readState);
                              if(readState){
                                readMode = 'webtoon';
                              }else{
                                readMode = 'manga';
                              }
                            });
                            
                          },
                          
                          ),
                          Icon(Icons.view_list),]),
                        Row(
                          children:[Text('Backgroud: '),
                            Icon(Icons.brightness_low),
                            Switch(
                          value: backgroundState,
                          onChanged: (bool s){
                            setState(() {
                              backgroundState =s;
                              print(backgroundState);
                              if(backgroundState){
                                bgColor = Colors.white;
                              }else{
                                bgColor = Colors.black;
                              }
                            });
                            
                          },
                          
                          ),
                          Icon(Icons.brightness_high),]
                        ),
                        
                        
                        
                        ])
                        ],
                    ),
                  );
              });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: bgColor,
      body:CustomScrollView(
        slivers:[SliverAppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(current.numero),
          floating: true,
          pinned: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back), 
          onPressed: (){
            Navigator.pop(context,manga);
          }),
          expandedHeight: 100.0,
          bottom: PreferredSize(                       // Add this code
                preferredSize: Size.fromHeight(16.0),      // Add this code
                child: Text(''),                           // Add this code
              ), 
          flexibleSpace:  FlexibleSpaceBar(background:Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                
                children:[
                   IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: (){
                      changeChap(current.prevUrl);
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: (){
                      changeChap(current.nextUrl);
                    },
                  ),
                ]
                ),
               
                
                ),
                
                
              
        
              actions: <Widget>[
                IconButton(
            icon: Icon(Icons.settings),
            onPressed: (){
              optionsForm();
            },
          ),
              ],
          
        ),
        SliverFillRemaining(child:new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              //form(),
              list(),
            ],
          ),
        ))
        ,
        ],
      
    ));
  }
}
