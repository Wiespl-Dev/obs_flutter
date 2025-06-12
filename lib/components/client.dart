import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = "http://127.0.0.1:5000"; // <- Correct port

class BaseClientAPI {
  final client = http.Client();

  Future<dynamic> askInfo(String api) async {
    try {
      final url = Uri.parse(baseUrl + api);
      final response = await client.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server error: ${response.statusCode}");
        return {"Error": "true"};
      }
    } catch (e) {
      print("Request error: $e");
      return {"Error": "true"};
    }
  }
}
