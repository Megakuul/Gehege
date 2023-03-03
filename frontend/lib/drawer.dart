import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/cupertino.dart';
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
              return const CupertinoActivityIndicator();
            }
            return const CupertinoActivityIndicator();
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

  List<Widget> getListTiles(Map<String, dynamic>? obj) {
    List<Widget> tempList = [];

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
    //Add Gehege
    if (obj["payload"]["administrator"]) {
      tempList.insert(2, gehegeAddItem());
    }
    tempList.insert(3, changeUserInfo(Description: obj["payload"]["description"]));
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          DrawerHeader(
            child: Transform.scale(
              scale: 5,
              child: const Icon(Icons.account_circle_rounded, color: Colors.white),
            ),
          ),
        ] + getListTiles(widget.obj)
    );
  }
}

class changeUserInfo extends StatefulWidget {
  final String Description;

  const changeUserInfo({required this.Description});

  @override
  _changeUserInfoState createState() => _changeUserInfoState();
}

class _changeUserInfoState extends State<changeUserInfo> {
  TextEditingController descriptionControlr = TextEditingController();
  TextEditingController passwordControlr = TextEditingController();

  void resetControlrs() {
    descriptionControlr.text = widget.Description;
    passwordControlr.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: const Text("Edit User"),
      leading: const Icon(Icons.add_box, color: Colors.white),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Edit Userinformation"),
              content: Column(
                children: [
                  TextField(
                    controller: descriptionControlr,
                    decoration: const InputDecoration(
                      hintText: "Description",
                    ),
                  ),
                  TextField(
                    controller: passwordControlr,
                    decoration: const InputDecoration(
                      hintText: "Password",
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetControlrs();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (passwordControlr.text.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text("Password must have at least 4 chars")
                          ),
                        );
                        Navigator.pop(context);
                        return;
                      }
                      Navigator.pop(context);
                      String? result = await changeuserinfo("$api_base_url/creategehege", {
                        "description": descriptionControlr.text,
                        "password": passwordControlr.text
                      });
                      if (result!=null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(result)
                            )
                        );
                      }
                      resetControlrs();
                    },
                    child: const Text("Submit")
                ),
              ],
            )
        );
        Navigator.pop(context);
      },
    );
  }
}

class gehegeAddItem extends StatefulWidget {
  @override
  _gehegeAddItemState createState() => _gehegeAddItemState();
}

class _gehegeAddItemState extends State<gehegeAddItem> {
  Uint8List? imageBytes;
  TextEditingController gehegeNameControlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: const Text("Add Gehege"),
      leading: const Icon(Icons.add_box, color: Colors.white),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Gehege"),
              content: Column(
                children: [
                  TextField(
                    controller: gehegeNameControlr,
                    decoration: const InputDecoration(
                      hintText: "Name",
                    ),
                  ),
                  imageBytes == null
                      ? const Text('No image selected')
                      : Image.memory(imageBytes!),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Select Image'),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final fileBytes = result.files.first.bytes;
                        setState(() {
                          imageBytes = fileBytes;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    gehegeNameControlr.text = "";
                    imageBytes = null;
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (imageBytes==null || gehegeNameControlr.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text("Select an image")
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    }
                    Navigator.pop(context);
                    String? result = await createGehege("$api_base_url/creategehege", {
                      "gehege_name": gehegeNameControlr.text,
                      "imageBase64String": base64Encode(imageBytes!.toList())
                    });
                    if (result!=null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(result)
                        )
                      );
                    }
                    gehegeNameControlr.text = "";
                    imageBytes = null;
                  },
                  child: const Text("Submit")
                ),
              ],
            )
        );
        Navigator.pop(context);
      },
    );
  }
}