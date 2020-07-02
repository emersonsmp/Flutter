import 'package:flutter/material.dart';

class Cadastro extends StatefulWidget {
  Cadastro();
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Cadastro"),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: new EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nomeController,
              decoration: InputDecoration.collapsed(hintText: "Nome"),
              onChanged: (text) {},
              onSubmitted: (text) {},
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration.collapsed(hintText: "Email"),
              onChanged: (text) {},
              onSubmitted: (text) {},
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration.collapsed(hintText: "Senha"),
              obscureText: true,
              onChanged: (text) {},
              onSubmitted: (text) {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          print(_nomeController.text);
          print(_emailController.text);
          print(_senhaController.text);
        },
      ),
    );
  }
}
