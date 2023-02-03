import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutterprojects/userPages.dart';

import 'apiConnector.dart';
import 'main.dart';

void clearToken() {
  document.cookie = "token=;";
  document.cookie = "username=;";
}

class MainDrawer extends StatefulWidget {
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late Future<Map<String, dynamic>> userinformation;

  @override
  Widget build(BuildContext context) {
    userinformation = getuserinfo("$api_base_url/getuserinfo");
    return Drawer(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.85),
        width: 300,
        child: FutureBuilder(
          future: userinformation,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return drawerBody(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        )
    );
  }
}

class drawerBody extends StatefulWidget {
  final Map<String, dynamic>? obj;

  const drawerBody(this.obj);

  State<drawerBody> createState() => _drawerBodyState();
}

class _drawerBodyState extends State<drawerBody> {

  List<ListTile> getListTiles(Map<String, dynamic>? obj) {
    List<ListTile> tempList = [];

    if (obj==null||obj["state"]!="Success") {
      tempList.add(
          ListTile(
            textColor: Colors.white,
            title: const Text("Log In"),
            leading: const Icon(Icons.login, color: Colors.white),
            onTap: () => {
              Navigator.pop(context),
              Navigator.push(context, MaterialPageRoute(builder: (context) => loginPage()))
            },
          )
      );
      return tempList;
    }

    tempList = [
      ListTile(
        textColor: Colors.white,
        title: Text(obj["payload"]["username"]),
        leading: const Icon(Icons.account_box_sharp, color: Colors.white),
      ),
      ListTile(
        textColor: Colors.white,
        title: Text(obj["payload"]["description"]),
        leading: const Icon(Icons.description, color: Colors.white),
      ),
      ListTile(
        textColor: Colors.white,
        title: Text(obj["payload"]["cash"].toString()),
        leading: const Icon(Icons.attach_money, color: Colors.white),
      ),
      ListTile(
        textColor: Colors.white,
        title: const Text("Log out"),
        leading: const Icon(Icons.logout, color: Colors.white),
        onTap: () {
          clearToken();
          Navigator.pop(context);
        },
      )
    ];
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          DrawerHeader(
            child: Transform.scale(
              child: const Icon(Icons.account_circle_rounded, color: Colors.white),
              scale: 5,
            ),
          ),
        ] + getListTiles(widget.obj)
    );
  }
}