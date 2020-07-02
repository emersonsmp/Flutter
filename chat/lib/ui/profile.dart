import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Perfil extends StatefulWidget {
  Perfil(this.user);
  final FirebaseUser user;

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = widget.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text(
          "Ola, " + _user.displayName.toString(),
        ),
        actions: <Widget>[
          _user != null
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
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                initState();
              })
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(_user.email.toString()),
        ],
      ),
    );
  }
}
