import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'news_info.dart';
enum NewsAction{
  Fetch,
  delete
}
class NewsBloc{
  final _stateStreamController=StreamController<List<Article>>();
  StreamSink<List<Article>> get newsSink => _stateStreamController.sink;
  Stream<List<Article>> get newsStream => _stateStreamController.stream;

  final _eventStreamController=StreamController<NewsAction>();
  StreamSink<NewsAction> get eventSink => _eventStreamController.sink;
  Stream<NewsAction> get eventStream => _eventStreamController.stream;

  NewsBloc()
  {
    eventStream.listen((event) async{
      if(event==NewsAction.Fetch){
        try {
          var news = await getNews();
          if(news !=null)
          newsSink.add(news.articles);
          else{
            newsSink.addError('something went wrong');
          }
        } on Exception catch (e) {
          newsSink.addError('something went wrong');
        }
      }
    });
  }
  Future<NewsModel> getNews() async {
    var client = http.Client();
    var newsModel;

    try {
      var response = await client.get(Uri.parse('https://newsapi.org/v2/everything?domains=wsj.com&apiKey=d89f4bf3d1ee442584ffdc4657f6d76d'));
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);

        newsModel = NewsModel.fromJson(jsonMap);
      }
    } catch (Exception) {
      return newsModel;
    }

    return newsModel;
  }
  void dispose(){
    _stateStreamController.close();
    _eventStreamController.close();
  }
}