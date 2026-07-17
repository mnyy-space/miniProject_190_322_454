import 'package:halalsefllearning/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppApi {
      static Future<http.Response> get(String url) async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
        String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
        print(fullUrl);

        final response = await http.get(
          Uri.parse(fullUrl),
          headers: <String, String>{
            'Content-Type' : 'application/json; charset=UTF-8',
            'Accept' : 'application/json',
            'authorization' : 'Bearer ${prefs.getString("access_token") ?? ""}'
          }
        );

        return response;
      }
}