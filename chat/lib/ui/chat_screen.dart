import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScren extends StatefulWidget {
  @override
  _ChatScrenState createState() => _ChatScrenState();
}

class _ChatScrenState extends State<ChatScren> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isloadingImage = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  //METODO PARA PEGAR O USUARIO OU REALIZAR O LOGIN
  Future<FirebaseUser> _getUser() async {
    //SE ESTIVER CONECTADO JÁ
    if (_currentUser != null) return _currentUser;

    try {
      //LOGIN NA CONTA DO GOOGLE
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      //PEGANDO OS DADOS DE AUTENTICAÇÃO DO GOOGLE
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      //PEGANDO OS TOKENS
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      //LOGIN NO FIREBASE
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      //PEGANDO USUARIO
      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  //METODO PARA ENVIO DAS MENSAGENS OU IMAGENS
  void _sendMenssage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();
    if (user == null) {
      _scafoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possivel fazer o login'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // #region CONTRUÇÃO DO MAPA DE DADOS
    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderphotourl": user.photoUrl,
      "time": Timestamp.now()
    };
    // #endregion

    // #region UPLOAD DA IMAGEM NO STORAGE DO FIREBASE
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(_currentUser.uid)
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isloadingImage = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgurl'] = url;

      setState(() {
        _isloadingImage = false;
      });
    }
    // #endregion

    if (text != null) data['text'] = text;

    Firestore.instance.collection('Message').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      //APPBAR DA TELA DE CHAT
      appBar: AppBar(
        //TITULO DA TELA DE CHAT
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        //BOTÃO LOGOUT
        actions: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
                icon: Icon(Icons.add_comment),
                onPressed: () {
                  print('Clicou');
                }),
          ),
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scafoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Você saiu com sucesso'),
                      ),
                    );
                  },
                )
              : Container(),
        ],
      ),

      //BODY DA TELA DO CHAT
      body: Column(
        children: <Widget>[
          Expanded(
            //CRIA DADOS NA TELA BASEADO NO ULTIMO SNAPSHOT
            child: StreamBuilder<QuerySnapshot>(
              // #region STREAM QUE SERA OUVIDO
              stream: Firestore.instance
                  .collection('Message')
                  .orderBy('time')
                  .snapshots(),
              // #endregion

              //BUILDER PARA CONSTRUIR OS DADOS
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // #region VALIDAÇÕES
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  // #endregion
                  default:
                    //PEGA OS DOCUMENTOS
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();

                    //LIST VIEW:
                    //COMO SE FOSSE UM FOR, VAI PASSANDO DADO POR DADO
                    //CHAT MESSAGE IRA SE ENCARREGAR DE CONSTRUIR
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        //CHAMA O METODO EM CHAT_MESSAGE PASSANDO DATA E TRUE/FALSE
                        return ChatMessage(documents[index].data,
                            documents[index].data['uid'] == _currentUser?.uid);
                      },
                    );
                }
              },
            ),
          ),
          //SE A IMAGEM ESTIVER CARREGAMENTO IRA MOSTRAR UM ELEMENTO DE CARREGAMENTO ABAIXO DA TELA
          _isloadingImage ? LinearProgressIndicator() : Container(),

          //ESSA FUNCAO DENTRO DE COMPOSER É A SENDMENSSAGE
          //QUE FOI DECLARADA DINAMICAMENTE EM TEXT_COMPOSER
          TextComposer(_sendMenssage),
        ],
      ),
    );
  }
}
