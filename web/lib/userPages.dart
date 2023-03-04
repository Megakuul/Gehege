import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterprojects/apiConnector.dart';
import 'package:flutterprojects/main.dart';

class loginPage extends StatefulWidget {

  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {

  TextEditingController username_contr = TextEditingController();
  TextEditingController password_contr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.black, blurRadius: 3,spreadRadius: 0.5,blurStyle: BlurStyle.outer)
            ],
            borderRadius: BorderRadius.circular(8)
          ),
          height: 450,
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                const Image(image: AssetImage("assets/Dinosaur.png"), width: 120, height: 70),
                const SizedBox(height: 20),
                const Text("Log In", style: TextStyle(fontSize: 30)),
                const SizedBox(height: 40),
                TextField(
                  controller: username_contr,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                      hintText: "username"
                  ),
                ),
                TextField(
                  controller: password_contr,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "password",
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => signupPage()))
                  },
                  child: const Text("No Account right now? Sign up",
                      style: TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)
                  )
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(elevation: 12.0),
                        onPressed: () => {
                          username_contr.text = "",
                          password_contr.text = "",
                          Navigator.pop(context)
                        },
                      )
                    ),
                    Expanded(child: Container()),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text("Log In", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(elevation: 12.0),
                        onPressed: () async {
                          String? error = await createtok(api_base_url + "/createtok", {
                            "username": username_contr.text,
                            "password": password_contr.text
                          });
                          if (error == null) {
                            username_contr.text = "";
                            password_contr.text = "";
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Error: $error"),
                                )
                            );
                          }
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}

class signupPage extends StatefulWidget {

  State<signupPage> createState() => _signupPageState();
}

class _signupPageState extends State<signupPage> {

  TextEditingController username_contr = TextEditingController();
  TextEditingController description_contr = TextEditingController();
  TextEditingController password_contr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Colors.black, blurRadius: 3,spreadRadius: 0.5,blurStyle: BlurStyle.outer)
                ],
                borderRadius: BorderRadius.circular(8)
            ),
            height: 450,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  const Image(image: AssetImage("assets/Dinosaur.png"), width: 120, height: 70),
                  const SizedBox(height: 20),
                  const Text("Sign up", style: TextStyle(fontSize: 30)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: username_contr,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                        hintText: "username"
                    ),
                  ),
                  TextField(
                    controller: description_contr,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                        hintText: "description"
                    ),
                  ),
                  TextField(
                    controller: password_contr,
                    enableSuggestions: true,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "password",
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(elevation: 12.0),
                            onPressed: () => {
                              username_contr.text = "",
                              description_contr.text = "",
                              password_contr.text = "",
                              Navigator.pop(context)
                            },
                          )
                      ),
                      Expanded(child: Container()),
                      Expanded(
                        child: ElevatedButton(
                          child: const Text("Sign up", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(elevation: 12.0),
                          onPressed: () async {
                            if (username_contr.text.length < 6 || password_contr.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Error: enter at minimum 6 characters"),
                                  )
                              );
                              return;
                            }
                            String? error = await signup(api_base_url + "/signup", {
                              "username": username_contr.text,
                              "password": password_contr.text,
                              "description": description_contr.text
                            });
                            if (error == null) {
                              username_contr.text = "";
                              password_contr.text = "";
                              description_contr.text = "";
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Error: $error"),
                                  )
                              );
                            }
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}