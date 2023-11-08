// Importando bibliotecas necessárias
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Configuração do Firebase
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyAHI077Xa2xCA0Z25-W-xjOrcN3Yyg0cBY",
    authDomain: "teste-vitoria.firebaseapp.com",
    projectId: "teste-vitoria",
    storageBucket: "teste-vitoria.appspot.com",
    messagingSenderId: "932456421799",
    appId: "1:932456421799:web:03afc2bd96dce5eef33e82");

// Widget principal

// Este é um código que estende a classe StatelessWidget.
// A classe representa o widget principal da aplicação.
class MyApp extends StatelessWidget {
  // O construtor recebe uma chave e chama o superconstrutor com ela.
  const MyApp({super.key});

  // Esse método cria a árvore de widgets para o aplicativo.
  @override
  Widget build(BuildContext context) {
   // Retorna um widget MaterialApp.
    return MaterialApp(
     // Oculta o banner de depuração.
      debugShowCheckedModeBanner: false,
      // Define o tema de luz para o aplicativo.
      theme: ThemeData.light(),
     // Define o tema escuro para o aplicativo.
      darkTheme: ThemeData.dark(),
     // Define o modo de tema para seguir a configuração do sistema.
      themeMode: ThemeMode.system,
      // Define as rotas para o aplicativo.
      routes: {
        "/lista": (context) => TaskList(),
        "/cadastro": (context) => TaskCreate(),
        "/login": (context) => Login(),
        "/register": (context) => Register(),
      },
      // Ele define a rota inicial como "/login".
      initialRoute: "/login",
    );
  }
}

// ! AV1
// Widget para exibir a lista de tarefas
class TaskList extends StatelessWidget {
  // Instância do Firestore
  final firestore = FirebaseFirestore.instance;

  // Construtor da classe
  TaskList({super.key});

  // Método build que retorna um Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título e botão de logout
      appBar: AppBar(
        title: const Text("Todo List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Logout',
            onPressed: () {
              // Fazer logout do usuário atual
              FirebaseAuth.instance.signOut();
              // Voltar para a tela anterior
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      // Botão de ação flutuante para adicionar novas tarefas
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("/cadastro"),
      ),
      // Corpo da tela com StreamBuilder para ouvir as alterações na coleção 'tasks'
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('tasks')
            .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Se o snapshot não tiver dados ou houver um erro, retorna um indicador de carregamento ou a mensagem de erro
          if (!snapshot.hasData) return const CircularProgressIndicator();
          if (snapshot.hasError) return Text(snapshot.error.toString());
          // Se o snapshot tiver dados, mapeia cada documento para um widget Dismissible
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

// ! AV1
// Widget para criar uma nova tarefa
class TaskCreate extends StatelessWidget {
  // Instância do Firestore
  final firestore = FirebaseFirestore.instance;
  // Controllers para os campos de texto
  final TextEditingController txtCtrl = TextEditingController();
  final TextEditingController categoriaCtrl = TextEditingController();

  // Construtor da classe
  TaskCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // AppBar vazio
        appBar: AppBar(),
        // Corpo da tela com SafeArea
        body: SafeArea(
          child: Column(
            children: [
              // Campo de texto para o nome da tarefa
              TextField(
                controller: txtCtrl,
                decoration: const InputDecoration(labelText: "Task"),
              ),
              // Campo de texto para a categoria da tarefa
              TextField(
                controller: categoriaCtrl,
                decoration: const InputDecoration(labelText: "Categoria"),
              ),
              // Botão para salvar a tarefa
              Container(
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Salvar"),
                  onPressed: () {
                    // Adicionar a tarefa ao Firestore
                    firestore.collection('tasks').add({
                      "name": txtCtrl.text,
                      "finished": false,
                      "categoria": categoriaCtrl.text,
                      "user": FirebaseAuth.instance.currentUser!.uid,
                    });
                    // Voltar para a tela anterior
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}



// ! AV2
// Widget para fazer o login
class Login extends StatelessWidget {
  // Controllers para os campos de texto
  final TextEditingController emailTxt = TextEditingController();
  final TextEditingController senhaTxt = TextEditingController();

  // Construtor da classe
  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título
      appBar: AppBar(
        title: const Text('Fazer Login'),
      ),
      // Corpo da tela com SafeArea
      body: SafeArea(
        child: Column(
          children: [
            // Campo de texto para o e-mail do usuário
            TextField(
              controller: emailTxt,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            // Campo de texto para a senha do usuário
            TextField(
              controller: senhaTxt,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            // Botão para entrar
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Entrar"),
                onPressed: () async {
                  // Tentar fazer login com e-mail e senha
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailTxt.text,
                      password: senhaTxt.text,
                    );
                    // Se bem-sucedido, navegar para a tela de lista
                    Navigator.of(context).pushNamed('/lista');
                  } catch (e) {
                    // Se falhar, mostrar mensagem de erro
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
            // Botão para navegar para a tela de registro
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


// ! AV2
// Widget para registrar-se
class Register extends StatelessWidget {
  // Controllers para os campos de texto
  final TextEditingController txtCtrl = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();

  // Construtor da classe
  Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título
      appBar: AppBar(
        title: const Text('Registrar-se'),
      ),
      // Corpo da tela com SafeArea
      body: SafeArea(
        child: Column(
          children: [
            // Campo de texto para o e-mail do usuário
            TextField(
              controller: txtEmail,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            // Campo de texto para a senha do usuário
            TextField(
              controller: txtCtrl,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            // Botão para registrar
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Registrar"),
                onPressed: () async {
                  // Verificar se a senha tem pelo menos 6 caracteres
                  if (txtCtrl.text.length >= 6) {
                    // Tentar registrar o usuário com e-mail e senha
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: txtEmail.text,
                        password: txtCtrl.text,
                      );
                      // Se bem-sucedido, navegar para a tela de login
                      Navigator.of(context).pushNamed('/login');
                    } catch (e) {
                      // Se falhar, imprimir o erro no console
                      print("Erro no registro: $e");
                    }
                  } else {
                    // Se a senha for muito curta, mostrar mensagem de erro
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

// classe e função qye vai Executar o app
void main() async {
  // Garantir que o binding de widgets esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar o Firebase de forma assíncrona
  await Firebase.initializeApp(options: firebaseConfig);
  // Iniciar a aplicação
  runApp(const MyApp());
}
