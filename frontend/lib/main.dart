import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterprojects/gehege.dart';
import 'drawer.dart';

import 'dart:convert';

String api_base_url = "Not loaded";

Future<void> main() async {
  runApp(const MyApp());
  api_base_url = await loadconfig();
}

Future<String> loadconfig() async {
  Map jsonString = const JsonDecoder().convert(await rootBundle.loadString('assets/gehege.conf.json'));
  return jsonString["api_url"] ?? "Not found";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gehege',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MainPage(title: 'Gehege'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => {
            _key.currentState!.openDrawer()
          },
        ),
        title: Text(widget.title),
      ),
      drawer: MainDrawer(),
      body: GehegeBody(),
    );
  }
}

