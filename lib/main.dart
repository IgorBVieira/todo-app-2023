import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyAJ0ADhleMm0YwvvNrF22kIkHJCpgIOjak",
    authDomain: "lp3-vitoria.firebaseapp.com",
    projectId: "lp3-vitoria",
    storageBucket: "lp3-vitoria.appspot.com",
    messagingSenderId: "535933998918",
    appId: "1:535933998918:web:dc88f65ece924aaf6db747");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routes: {
        "/lista": (context) => TaskList(),
        "/cadastro": (context) => TaskCreate(),
        "/login": (context) => Login(),
        "/register": (context) => Register(),
      },
      initialRoute: "/login",
    );
  }
}

class TaskList extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;

  TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Logout',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("/cadastro"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('tasks')
            .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          if (snapshot.hasError) return Text(snapshot.error.toString());
          var docs = snapshot.data!.docs;
          return ListView(
            scrollDirection: Axis.vertical,
            children: docs
                .map((doc) => Dismissible(
                    key: Key(doc.id),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) => doc.reference.delete(),
                    child: Card(
                      child: CheckboxListTile(
                        title: Text(doc['name']),
                        subtitle: Text(doc['categoria']),
                        value: doc['finished'],
                        onChanged: (value) => doc.reference.update({
                          "finished": value!,
                        }),
                      ),
                    )))
                .toList(),
          );
        },
      ),
    );
  }
}

class TaskCreate extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;
  final TextEditingController txtCtrl = TextEditingController();
  final TextEditingController categoriaCtrl = TextEditingController();

  TaskCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Column(
            children: [
              TextField(
                controller: txtCtrl,
                decoration: const InputDecoration(labelText: "Task"),
              ),
              TextField(
                controller: categoriaCtrl,
                decoration: const InputDecoration(labelText: "Categoria"),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Salvar"),
                  onPressed: () {
                    firestore.collection('tasks').add({
                      "name": txtCtrl.text,
                      "finished": false,
                      "categoria": categoriaCtrl.text,
                      "user": FirebaseAuth.instance.currentUser!.uid,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class Login extends StatelessWidget {
  final TextEditingController emailTxt = TextEditingController();
  final TextEditingController senhaTxt = TextEditingController();

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Login'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: emailTxt,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: senhaTxt,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Entrar"),
                onPressed: () async {
                  try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailTxt.text,
                      password: senhaTxt.text,
                    );
                    Navigator.of(context).pushNamed('/lista');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-mail ou Senha inválidos.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    print("Erro na autenticação: $e");
                  }
                },
              ),
            ),
            TextButton(
              child: const Text("Não tem conta, registre-se"),
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Register extends StatelessWidget {
  final TextEditingController txtCtrl = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();

  Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar-se'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: txtEmail,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: txtCtrl,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Registrar"),
                onPressed: () async {
                  if (txtCtrl.text.length >= 6) {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: txtEmail.text,
                        password: txtCtrl.text,
                      );
                      Navigator.of(context).pushNamed('/login');
                    } catch (e) {
                      print("Erro no registro: $e");
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Senha inválida. Deve conter pelo menos 6 caracteres.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}
