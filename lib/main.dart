import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyAooLwSI1t94F4fWoNU-w3Xq7vmzufgER8",
  authDomain: "todo-list-f6ea1.firebaseapp.com",
  projectId: "todo-list-f6ea1",
  storageBucket: "todo-list-f6ea1.appspot.com",
  messagingSenderId: "301455416677",
  appId: "1:301455416677:web:58bb92ca1e34019f78d58c",
);

class MyApp extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Logout',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("/cadastro"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('tasks')
            .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
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
  TextEditingController txtCtrl = TextEditingController();
  TextEditingController categoriaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Column(
            children: [
              TextField(
                controller: txtCtrl,
                decoration: InputDecoration(labelText: "Task"),
              ),
              TextField(
                controller: categoriaCtrl,
                decoration: InputDecoration(labelText: "Categoria"),
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                  child: Text("Salvar"),
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
  TextEditingController emailTxt = TextEditingController();
  TextEditingController senhaTxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fazer Login'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: emailTxt,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: senhaTxt,
              decoration: InputDecoration(labelText: "Senha"),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Entrar"),
                onPressed: () async {
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailTxt.text,
                      password: senhaTxt.text,
                    );
                    Navigator.of(context).pushNamed('/lista');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
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
              child: Text("Não tem conta, registre-se"),
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
  TextEditingController txtCtrl = TextEditingController();
  TextEditingController txtEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar-se'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: txtEmail,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: txtCtrl,
              decoration: InputDecoration(labelText: "Senha"),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Registrar"),
                onPressed: () async {
                  if (txtCtrl.text.length >= 6) {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
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
                      SnackBar(
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
  runApp(MyApp());
}
