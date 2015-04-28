
import 'dart:html';

abstract class Comm {
 save() {
   
 }

 load() {

 }

 void getPicture(String baseURL) {
   var request = new HttpRequest();
   request.open('GET', baseURL);

   request.onLoad.listen((event) => print(
       'Request complete ${event.target.reponseText}'));

   request.send();
 }

 void getSessionIndex(String baseURL, String session, Function onLoad) {
   var request = HttpRequest.getString(baseURL + '/idx/' + session).then(onLoad);
   
/*   var request = new HttpRequest();
   request.open('GET', baseURL + '/idx/' + session);

   request.onLoad.listen((event) => print(
       'Request complete ${event.target.reponseText}'));

   request.send(); */
 }

// toJson();
}