import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pk_test/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pk_test/usertype.dart';
import 'firebase_options.dart';
import 'config.dart';
import 'package:justpassme_flutter/justpassme_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Toure',
      theme: ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.black12),
      home: const MyHomePage(title: 'Welcome to Toure App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final justPassMeClient = JustPassMe();
  final user = FirebaseAuth.instance.currentUser;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 110,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try{
                final userToken = await user?.getIdToken();
                await justPassMeClient.register(registrationUrl,
                  {"Authorization": "Bearer $userToken"});
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('${e}'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailcontroller.text,
                              password: passwordcontroller.text)
                          .then((value) => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) => const UserType()),),
                                print("Account created")
                              })
                          .catchError((error) => {
                                print("Failed to create user: $error"),
                              });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 117, 33, 243)),
                    ),
                    child: const Text('Sign up'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 110,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 119, 26, 140)),
                    ),
                    child: const Text('Login'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
