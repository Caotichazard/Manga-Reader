


class Manga{
    int id;
    String title;
    String url;
    String cover;
    String lastChapNum;
    String lastChapUrl;
    String author;
    String genres;
    String status;


    //Manga(this.url, this.titulo, this.capa, this.capRecente);
    Manga(this.id,this.url,this.title,this.cover,this.lastChapNum,this.lastChapUrl,this.author,this.genres,this.status);
    
    


    Map<String, dynamic> toMap(){
      var map = <String, dynamic>{
        'id': id,
        'url': url,
        'title': title,
        'cover': cover,
        'lastChapNum': lastChapNum,
        'lastChapUrl': lastChapUrl,
        'author': author,
        'genres': genres,
        'status': status,
      };
      return map;
    }

    Manga.fromMap(Map<String, dynamic> map){
      id = map['id'];
      url = map['url'];
      title = map['title'];
      cover= map['cover'];
      lastChapNum = map['lastChapNum'];
      lastChapUrl = map['lastChapUrl'];
      author = map['author'];
      genres =  map['genres'];
      status = map['status'];
    }
    
}