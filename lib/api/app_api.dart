import 'package:halalsefllearning/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppApi {
      static Future get(String url) async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
          print("${AppConfig.apiBaseUri}/${url}");

          final response = await http.get(
            Uri.parse("${AppConfig.apiBaseUri}/${url}"),
            headers: <String, String>{
              'Content-Type' : 'application/json; charset-UTF-8',
              'Accept' : 'application/json',
              'authorization' : 'Bearer ${prefs.getString("access_token")}'
            }
          );

          return response;
      }

}