
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import 'package:socorro/Helpers/scraper_helper.dart';
import 'package:socorro/Models/manga.dart';
import 'package:socorro/Helpers/db_helper.dart';




class MangaCollection extends StatefulWidget {
  MangaCollection({Key key, this.title}) : super(key: key);

  

  final String title;

  @override
  _MangaCollectionState createState() => _MangaCollectionState();
}

class _MangaCollectionState extends State<MangaCollection> {
  //
  Future<List<Manga>> mangas;
  TextEditingController _mangaurlcontroller = TextEditingController();
  String name;
  int curUserId;

  final _formKey = new GlobalKey<FormState>();
  var dbHelper;
  var scrapHelper;
  

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    scrapHelper = SCHelper();
    refreshList();
    
  }

  refreshList() {
    setState(() {
      mangas = dbHelper.getMangas();
    });
  }

  clearName() {
    _mangaurlcontroller.text = '';
  }

  validate() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
     
      final manga = await scrapHelper.getMangaInfo(_mangaurlcontroller.text);
      await dbHelper.saveManga(manga);
      scrapHelper.updateCapsNovos(manga);
      clearName();
      refreshList();
    }
  }

  form(){
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
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Insira o URL de um manga específico"),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Insira o URL';
                                      }
                                      return null;
                                    },
                                    controller: _mangaurlcontroller,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  child: Text("Salvar"),
                                  onPressed: () {
                                    validate();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
              });
  }

  GridView dataTable(List<Manga> mangas) {
    return GridView.count(
       scrollDirection: Axis.vertical,
      crossAxisCount: 3,
      childAspectRatio: MediaQuery.of(context).size.height/(MediaQuery.of(context).size.width*3),
      padding: EdgeInsets.only(left:10,right:10),
      
      children:  mangas
            .map(
              (manga) => Card(
                child:InkWell(child: Stack(
                  
                  children: [
                   Center(child:Container(
                     child:CachedNetworkImage(imageUrl: manga.cover),
                     margin: EdgeInsets.all(2),
                     )
                     ),
                    Positioned(
                      bottom: 0,
                      child:SizedBox(
                      width: MediaQuery.of(context).size.width/3.3,
                      
                      
                      child: Container(
                        color: Colors.white,
                       
                        child:Column(
                        
                        children: [ 
                                  Container(child:Text(
                                    manga.title.replaceAll('[', '').replaceAll(']', ''),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      
                                  ),
                                  margin: EdgeInsets.all(2), 
                                  ),
                                  Container(
                                    color: Colors.blueAccent,
                                    
                                    child:Center(child:Text(
                                    manga.lastChapNum,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      
                                  )),
                                  margin: EdgeInsets.all(2), 
                                  ),
                                ],
                      )),)
                    )],
                ),
                onTap: (){
                  Navigator.of(context).pushNamed('/manga', arguments: manga);
                },
                ),
                
                
            )).toList(),
    );
  }

  list() {
    return Container(
      child:Expanded(
      child:RefreshIndicator(child:  FutureBuilder(
        future: mangas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
      onRefresh: ()async {
        return await refreshList();
      },
      )
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              form();
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
            //form(),
            list(),
          ],
        ),
      ),
    );
  }
}
