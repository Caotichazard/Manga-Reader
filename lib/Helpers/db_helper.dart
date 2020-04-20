import 'dart:async';
import 'package:socorro/Models/capitulo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:socorro/Models/manga.dart';

class DBHelper {
  static Database _db;
  
  //table mangas
  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String URL = 'url';
  static const String COVER = 'cover';
  static const String RECENT = 'lastChapNum';
  static const String RECENTADDR = 'lastChapUrl';
  static const String AUTHOR = 'author';
  static const String GENRES = 'genres';
  static const String STATUS = 'status';
  

  //table mangachaps
  static const String MangaChapNum = 'numero';
  static const String MangaChapUrl = 'url';
  static const String MangaChapRead = 'read';
  static const String MangaChapNew = 'newChap';
  static const String MangaNextUrl = 'nextUrl';
  static const String MangaPrevUrl = 'prevUrl';
  static const String MangaChapManga = 'manga';

  static const String TABLE = 'MangaCollection';
  static const String DB_NAME = 'manga_db.db';
  
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db
        .execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $URL TEXT, $TITLE TEXT, $COVER TEXT, $RECENT TEXT,$RECENTADDR TEXT, $AUTHOR TEXT, $GENRES TEXT, $STATUS TEXT)");
  }

  Future<Manga> saveManga(Manga manga) async {
    var dbClient = await db;
    String mangaID = manga.title;
    manga.id = await dbClient.insert(TABLE, manga.toMap());
    
    await dbClient
        .execute("CREATE TABLE $mangaID ($ID INTEGER PRIMARY KEY,$MangaChapManga TEXT, $MangaChapNum TEXT, $MangaChapUrl TEXT, $MangaChapRead INTEGER, $MangaChapNew INTEGER, $MangaNextUrl TEXT, $MangaPrevUrl TEXT)");

    return manga;
  }

  Future<List<Manga>> getMangas() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, URL, TITLE, COVER, RECENT,RECENTADDR,AUTHOR,GENRES,STATUS]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Manga> mangas = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        mangas.add(Manga.fromMap(maps[i]));
      }
    }
    return mangas;
  }

  Future<int> deleteManga(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> updateManga(Manga manga) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, manga.toMap(),
        where: '$ID = ?', whereArgs: [manga.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }


  Future<Capitulo> saveChap(Capitulo capitulo, Manga manga) async {
    var dbClient = await db;
    capitulo.id = await dbClient.insert(manga.title, capitulo.toMap());
    return capitulo;
  }

  Future<List<Capitulo>> getChaps(String mangaId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(mangaId, columns: [ID,MangaChapManga, MangaChapNum,MangaChapUrl,MangaChapRead,MangaChapNew,MangaNextUrl,MangaPrevUrl]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Capitulo> capitulos = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        capitulos.add(Capitulo.fromMap(maps[i]));
      }
    }
    return capitulos;
  }

  Future<int> updateChap(Capitulo capitulo, String manga) async {
    var dbClient = await db;
    return await dbClient.update(manga, capitulo.toMap(),
        where: '$ID = ?', whereArgs: [capitulo.id]);
  }

  Future<Capitulo> getSingleChap(String mangaId,String url) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(mangaId, columns: [ID,MangaChapManga, MangaChapNum,MangaChapUrl,MangaChapRead,MangaChapNew,MangaNextUrl,MangaPrevUrl]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        Capitulo cap = Capitulo.fromMap(maps[i]);
        if(cap.url == url){
          return cap;
        }
      }
    }
    return null;
  }

  
}
