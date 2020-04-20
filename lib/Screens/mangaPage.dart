
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


import 'package:socorro/Helpers/scraper_helper.dart';
import 'package:socorro/Models/capitulo.dart';
import 'package:socorro/Helpers/db_helper.dart';
import 'package:socorro/Models/manga.dart';




class MangaPage extends StatefulWidget {

  final Manga data;
  final String title;

  MangaPage({
    Key key,
    this.title,
    @required this.data,
  }) : super(key: key);
 

  

  
  

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  

  var dbHelper;
  var scrapHelper;
  Future<List<Capitulo>> capitulos;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    scrapHelper = SCHelper();
     updateChaps();
    refreshList();
  }
  

  refreshList(){
    setState(() {
      capitulos = dbHelper.getChaps(widget.data.title);
    });
  }

  updateChaps(){
      
      setState(() {
        scrapHelper.updateCapsNovos(widget.data);
        capitulos = dbHelper.getChaps(widget.data.title);
      
    });
  }

  GridView dataTable(List<Capitulo> capitulos) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount: 4,
      childAspectRatio: 2.0,
      padding: EdgeInsets.only(left:10,right:10),

      children: capitulos.reversed
            .map(
              (capitulo) =>
              SizedBox(
                height: 200.0,
                width: 100.0,
                child: Card(
                          child:
                          InkWell( 
                            child:Center(child:Text(
                              capitulo.numero
                              )),
                            onTap: () async {
                              Capitulo capituloUp = capitulo;
                              capituloUp.read = 1;
                              capituloUp.newChap = 0;
                              await dbHelper.updateChap(capituloUp,widget.data.title);
                              Manga mangaUp = widget.data;
                              mangaUp.lastChapNum = capituloUp.numero;
                              mangaUp.lastChapUrl = capituloUp.url;
                              await dbHelper.updateManga(mangaUp);
                              Navigator.of(context).pushNamed('/manga/reader',  arguments: capitulo);
                            },
                          ),
                        
                        color: capitulo.newChap == 1? Colors.red: capitulo.read== 0? Colors.white:Colors.grey,
                        
                )
              )
            )
            .toList(),
            
      
    );
  }

  list() {
    return Container(child:
     Expanded(
      child: RefreshIndicator(child:FutureBuilder(
        future: capitulos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            
            return dataTable(snapshot.data);
          }

          if (snapshot.data == null ) {
            return Center(
              child: CircularProgressIndicator(),
              );
          }

          
        },
      ),
      onRefresh: ()async {
            
            return await updateChaps();
          },
      )
    ),
   
    )
    ;
  }
  
  Container mangaInfo(){
    return Container(
        height:  200,
        
          child:Row(
          children:[
            
             
              Container(child:Image.network(
                widget.data.cover,
                ),
                margin: EdgeInsets.all(10),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 10, right: 20),
                      width: MediaQuery.of(context).size.width*0.5,
                      child:
                      Text(
                        widget.data.title.replaceAll('[', '').replaceAll(']', ''),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          
                      ),
                    
                    ),
                   
                    Row(children: <Widget>[Container(
                      margin: EdgeInsets.only(left: 10, top: 10, right: 20),
                      width: MediaQuery.of(context).size.width*0.5,
                      child:
                      Text(
                        widget.data.author,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          
                      ),
                    
                    ),],),
                    Row(children: <Widget>[Container(
                      margin: EdgeInsets.only(left: 10, top: 10, right: 20),
                      width: MediaQuery.of(context).size.width*0.5,
                      child:
                      Text(
                        widget.data.genres,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          ),
                          
                          
                      ))],),
                    Row(children: <Widget>[Container(
                      margin: EdgeInsets.only(left: 10, top: 10, right: 20),
                      width: MediaQuery.of(context).size.width*0.5,
                      child:
                      Text(
                        widget.data.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          
                      ))],),
                       Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 8, top: 10, right: 20),
                          
                          height: 40,
                          
                          child: Card(
                            
                            child:InkWell(
                                child:Center(
                                  child: Container(
                                    
                                    child:Text(
                                        "Ler "+widget.data.lastChapNum,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),  
                                      ),
                                      margin: EdgeInsets.all(5),
                                    )
                                  ),
                                  onTap: ()async {
                                    for(Capitulo cap in await capitulos){
                                      if(cap.url == widget.data.lastChapUrl){
                                        Capitulo capituloUp = cap;
                                        capituloUp.read = 1;
                                        dbHelper.updateChap(capituloUp,widget.data.title);
                                      }
                                    }
                                    Capitulo capitulo = await dbHelper.getSingleChap(widget.data.title,widget.data.lastChapUrl);
                                    Navigator.of(context).pushNamed('/manga/reader',  arguments: capitulo );
                                  },
                              ),
                              
                            ),
                        )
                      ]
                    ),
                  ])
            ],
              
                ),
                
      
      );
  }
  

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(''),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              dbHelper.deleteManga(widget.data.id,widget.data.title);
            },
          ),
        ],
        
      ),
      body: new Container(
        
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              
              mangaInfo(),
              list(),
            ],
          ),
          
      
      )
      
    );
  }
}
