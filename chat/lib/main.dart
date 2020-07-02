import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:chat/text_composer.dart';
import 'package:chat/ui/cadastro.dart';
import 'package:chat/ui/chat_screen.dart';
import 'package:chat/ui/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  runApp(MyApp());

  // #region metodos firebase
  //ESCRITA FIREBASE---------------------------------------------------------------------------------------------------------

  //DOCUMENT VAZIO O FIREBASE GERA CHAVE AUTOMATICA
  //Firestore.instance.collection('Mensagens').document().setData({'text': 'Tudo', 'From': 'Jose', 'Read': false});

  //UPDATE VALOR: ALTERA SÓ UM DADO POR EXEMPLO.
  //Firestore.instance.collection('Mensagens').document().updateData({'Read': false});

  //CRIANDO COLEÇÃO DE ARQUIVOS
  //Firestore.instance.collection('Mensagens').document('y3fg6Ys8qBO8CbziBFTd').collection('Arquivos').document().setData({'ArqName': 'Image.jpg'});

  //LEITURA FIREBASE----------------------------------------------------------------------------------------------------------

  /*QuerySnapshot snapshot = await Firestore.instance.collection('Mensagens').getDocuments();
  snapshot.documents.forEach((d) {
    //print(d.data);
    //print(d.documentID);

    //Update em todos os documents
    //d.reference.updateData({'hora': '00:00'});
  });*/

  //LEITURA DE UM DOC ESPECIFICO
  /*DocumentSnapshot Docsnapshot = await Firestore.instance
      .collection('Mensagens')
      .document('y3fg6Ys8qBO8CbziBFTd')
      .get();

  print(Docsnapshot.data);*/

  //LISTEM: VAI RETORNAR SEMPRE QUE HOUVER UMA MUDANÇA NA COLEÇÃO
  /* Firestore.instance.collection('Mensagens').snapshots().listen((dado) {
    dado.documents.forEach((d) {
      print(d.data);
    });
  }); */

  //LISTEM: VAI RETORNAR SEMPRE QUE HOUVER UMA MUDANÇA NO DOCUMENT
  /* Firestore.instance
      .collection('Mensagens')
      .document('y3fg6Ys8qBO8CbziBFTd')
      .snapshots()
      .listen((dado) {
    print(dado.data);
  }); */
  // #endregion
  //FirebaseUser user1 = await signUp("emerson@gmail.com", "senhahard1234");
  // await sleep(10);
  //String nome = nomeTempo(5);
  //FirebaseUser user2 = await signIn("emerson@gmail.com", "senhahard1234");
  //print(user.uid);
  //sleep(5);
  //auth.signOut();
  //print("Seu nome é: " + nome);
  //getJSONData();
}

Future sleep(tempo) {
  return new Future.delayed(
      Duration(seconds: tempo), () => print("10 seconds later."));
}

String nomeTempo(tempo) {
  List<String> names = ["Pedro", "Ricardo", "Mauricio", "Alex", "Mauro"];
  Future.delayed(Duration(seconds: tempo), () => print("10 seconds later."));
  int min = 0, max = 5;
  Random rnd = new Random();
  int r = min + rnd.nextInt(max - min);

  return names[r];
}

Future<FirebaseUser> signUp(email, password) async {
  try {
    final FirebaseUser user = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password))
        .user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<FirebaseUser> signIn(email, password) async {
  try {
    FirebaseUser user = (await auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool> getJSONData() async {
  var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/todos/1"),
      headers: {"Accept": "application/json"});
  // otem os dados JSON
  var data = json.decode(response.body);
  print(data);

  return true;
}

// #region MYAPP

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          iconTheme: IconThemeData(color: Colors.blue)),
      //home: ChatScren(),
      home: LoginPage(),
    );
  }
}
// #endregion
