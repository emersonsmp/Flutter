import 'package:chat/ui/chat_screen.dart';
import 'package:chat/ui/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser _currentUser;
final GoogleSignIn googleSignIn = GoogleSignIn();

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser _user = null;

  //FirebaseUser _currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40, left: 40, right: 40),
        color: Colors.grey[300],
        child: ListView(
          children: <Widget>[
            //LOGO DA TELA DE LOGIN
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset("images/logo.png"),
            ),
            //ENTRADA DE EMAIL
            TextFormField(
              // autofocus: true,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
            //ESPAÇO
            SizedBox(
              height: 10,
            ),
            //ENTRADA DE SENHA
            TextFormField(
              // autofocus: true,
              controller: _senhaController,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
            //ESPAÇO
            SizedBox(
              height: 10,
            ),
            //RESETAR PASSWORD
            Container(
              height: 40,
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                  "Recuperar Senha",
                  textAlign: TextAlign.right,
                ),
                onPressed: () {},
              ),
            ),
            //ESPAÇO
            SizedBox(
              height: 10,
            ),
            //LOGIN
            Container(
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [
                    Colors.blue[400],
                    Colors.blue[100],
                  ],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: SizedBox.expand(
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Icon(Icons.lock, color: Colors.blue)
                    ],
                  ),
                  onPressed: () async {
                    FirebaseUser user = await signIn(
                        _emailController.text, _senhaController.text);
                    //VALIDAÇÃO
                    user != null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Perfil(user),
                            ),
                          )
                        : print("---------------Erro Login-----------");
                  },
                ),
              ),
            ),
            //ESPAÇO
            SizedBox(
              height: 10,
            ),
            //FAZER LOGIN COM O GOOGLE (comentado)
            Container(
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: SizedBox.expand(
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Login com Google",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        child: SizedBox(
                          child: Image.asset("images/google.png"),
                          height: 20,
                          width: 20,
                        ),
                      )
                    ],
                  ),
                  onPressed: () async {
                    _user = await _getUser();
                    if (_user == null) {
                      _scafoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text('Não foi possivel fazer o login'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      //SE LOGIN FOR REALIZADO COM SUCESSO VA PARA TELA DE CHAT
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Perfil(_user),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            //ESPAÇO
            SizedBox(
              height: 10,
            ),
            //CADASTRE-SE
            Container(
              height: 40,
              child: FlatButton(
                child: Text(
                  "Cadastre-se",
                  textAlign: TextAlign.center,
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
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
}

Future<FirebaseUser> signIn(email, password) async {
  try {
    FirebaseUser user = (await auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    //validação
    assert(user != null);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);
    return user;

    //erro
  } catch (e) {
    print(e);
    return null;
  }
}
