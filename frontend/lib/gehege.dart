import 'dart:convert';

import 'apiConnector.dart';
import 'package:flutter/material.dart';

import 'main.dart';

late Future<Map<String, dynamic>> gehege;

class GehegeBody extends StatefulWidget {
  State<GehegeBody> createState() => _GehegeBodyState();
}

class _GehegeBodyState extends State<GehegeBody> {

  Widget GehegeList(Map<String, dynamic>? obj) {
    List<Widget> tempList = [];

    if (obj==null) {
      return const Text("Failed to load Gehege");
    }
    List<dynamic> list = obj['gehege'];

    int i = 0;
    for (var value in list) {

      try {
        tempList.add(kaefig(
            value['name'],
            value['image'],
            value['donations'],
            i
        ));

      } catch (error) {
        print("Failed to create gehege, invalid database entry");
      }
      i++;
    }
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 30,
      crossAxisSpacing: 0,
      childAspectRatio: 1.2/1,
      children: tempList,
    );
  }

  @override
  Widget build(BuildContext context) {
    gehege = getgehege("$api_base_url/getgehege");
    return Center(
        child: FutureBuilder(
          future: gehege,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GehegeList(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        )
    );
  }
}

class kaefig extends StatefulWidget {
  final String text;
  final String base64Image;
  final int index;
  int cash;

  kaefig(this.text, this.base64Image, this.cash, this.index);



  @override
  State<kaefig> createState() => _kaefig();
}

class _kaefig extends State<kaefig> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gehege = getgehege("$api_base_url/getgehege");
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.memory(base64Decode(widget.base64Image)),
              const Image(
                image: AssetImage("assets/kaefig.png"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 5),
          child: Text(widget.text),
        ),
        ElevatedButton(
          onPressed: () async {
            var obj = await gehege;
            String? error = await donate(api_base_url + "/donate", {
              "gehegename": widget.text,
              "cash": 1
            });
            if (error!=null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Error: $error"),
                  )
              );
            } else {
              setState(() {
                widget.cash = obj['gehege'][widget.index]['donations'] + 1;
              });
            }
          },
          style: ElevatedButton.styleFrom(
              elevation: 12.0,
              textStyle: const TextStyle(color: Colors.white)
          ),
          child: Text('Spenden ${widget.cash.toString()}'),
        ),
      ],
    );
  }
}