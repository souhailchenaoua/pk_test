import 'package:flutter/material.dart';
import 'package:pk_test/usertype.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config.dart';
import 'package:justpassme_flutter/justpassme_flutter.dart';
import 'package:dio/dio.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final justPassMeClient = JustPassMe();
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Toure'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              color: Colors.white,
              width: 350,
              height: 50,
              child: TextField(
                controller: emailcontroller,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter Email",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                width: 350,
                height: 50,
                child: TextField(
                  controller: passwordcontroller,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                )),
            Container(
              margin: const EdgeInsets.all(10),
              color: Colors.white,
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: emailcontroller.text,
                          password: passwordcontroller.text)
                      .then((value) => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserType()),
                            ),
                            print("Login Successful")
                          })
                      .catchError((error) => {print("$error")});
                },
                child: const Text('Login'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              color: Colors.white,
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await justPassMeClient.login(loginUrl, {});
                    String? token = result['token'] as String?;
                    if (token != null) {
                      await FirebaseAuth.instance.signInWithCustomToken(token);
                    }
                  } catch (e) {
                    print('${e}');
                    dio.interceptors.add(
                    LogInterceptor(requestBody: true, responseBody: true));
                    final response = await dio.get('$loginUrl');
                    print(response.data);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('$e'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Login with JustPassMe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
