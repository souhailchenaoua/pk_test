import 'package:flutter/material.dart';
import 'package:pk_test/usertype.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config.dart';
import 'package:justpassme_flutter/justpassme_flutter.dart';
import 'package:dio/dio.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

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
                      print('succesful login');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserType()),
                      );
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
            Container(
              margin: const EdgeInsets.all(10),
              color: Colors.white,
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    sendSignInLink();
                  } catch (e) {}
                },
                child: const Text('Passwordless Login '),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendSignInLink() async {
    String email = emailcontroller.text;

    if (email.isNotEmpty) {
      try {
        ActionCodeSettings acs = ActionCodeSettings(
          url: 'https://pktest01.page.link/y1E4',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.pk_test',
          androidPackageName: 'com.example.pk_test',
          androidInstallApp: true,
          androidMinimumVersion: '12',
        );

        await FirebaseAuth.instance.sendSignInLinkToEmail(
          email: email,
          actionCodeSettings: acs,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication link sent to $email')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send authentication link')),
        );
        print('Error sending email verification: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address')),
      );
    }
  }
}
