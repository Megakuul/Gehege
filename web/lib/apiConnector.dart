import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getgehege(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Gehege');
  }
}

Future<String?> signup(String uri, Object body) async {
  final response = await http.post(Uri.parse(uri), body: json.encode(body), headers: {"Content-Type": "application/json"});

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["state"]!="Success") {
      return jsonDecode(response.body)["error"];
    }
    return null;
  } else {
    return response.statusCode.toString();
  }
}

Future<String?> createGehege(String uri, Object body) async {
  final response = await http.post(Uri.parse(uri), body: json.encode(body), headers: {"Content-Type": "application/json"});

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["state"]!="Success") {
      return jsonDecode(response.body)["error"];
    }
    return null;
  } else {
    return response.statusCode.toString();
  }
}

Future<String?> createtok(String uri, Object body) async {
  final response = await http.post(Uri.parse(uri), headers: {"Content-Type": "application/json"}, body: json.encode(body));

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["state"]!="Success") {
      return jsonDecode(response.body)["error"];
    }
    return null;
  } else {
    return response.statusCode.toString();
  }
}

Future<Map<String, dynamic>> getuserinfo(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch userinfo');
  }
}

Future<String?> changeuserinfo(String uri, Object body) async {
  final response = await http.post(Uri.parse(uri), headers: {"Content-Type": "application/json"}, body: json.encode(body));

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["state"]!="Success") {
      return jsonDecode(response.body)["error"];
    }
    return null;
  } else {
    return response.statusCode.toString();
  }
}

Future<String?> donate(String uri, Object body) async {
  final response = await http.post(Uri.parse(uri), headers: {"Content-Type": "application/json"}, body: json.encode(body));

  if (response.statusCode == 200) {
    if (jsonDecode(response.body)["state"]!="Success") {
      return jsonDecode(response.body)["error"];
    }
    return null;
  } else {
    return response.statusCode.toString();
  }
}



