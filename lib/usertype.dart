import 'package:flutter/material.dart';
import 'package:pk_test/config.dart';
import 'package:pk_test/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:justpassme_flutter/justpassme_flutter.dart';
import 'package:dio/dio.dart';
class UserType extends StatefulWidget {
  const UserType({super.key});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final justPassMeClient = JustPassMe();
  final user = FirebaseAuth.instance.currentUser;
  final dio = Dio();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 117, 33, 243)),
            ),
              child: const Text('I am a Rider'),
            )),
        Container(
            margin: const EdgeInsets.all(10),
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 119, 26, 140)),
            ),
              child: const Text('I am a Driver'),
            ),
        ),
        ],
        ),
        Container(
          margin: const EdgeInsets.all(10),
          width: 150,
          height: 50,
        child: ElevatedButton(
         onPressed: () async{
          try{
                final token = await user?.getIdToken();
                final headers = {"Authorization" : "Bearer $token"};
                await justPassMeClient.register(registrationUrl, headers);
                print("Registered to JustPassMe");

              } catch (e) {
                 dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
                          final response = await dio.get('$baseUrl');
                          print(response.data);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text('${e}'),
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
         child: const Text('Register to JustPassMe'),
       ),
        ),
        ElevatedButton(
         onPressed: () async{
          await FirebaseAuth.instance.signOut();
          print("Signed out");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
         },
         child: const Text('Logout'),
       ),
       
      ],

    );

  }
}
