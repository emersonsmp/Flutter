//TELA DO CACOTATO - EDICAO E CRIAÇÃO
import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //CONTRALADORES DAS ENTRADAS DE TEXTO
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  //PARA DAR FOCUS EM UMA ENTRADA NAO PREENCHIDA
  final _nameFocus = FocusNode();

  //FLAG PARA VER SE FOI EDITADO A INFO
  bool _userEdited = false;

  //CONTA EDITADA
  Contact _editedContact;

  //INITSTATE VAI INCIAR O ESTADO DA TELA
  @override
  void initState() {
    super.initState();

    //SE VEIO PARA CADASTRAR
    if (widget.contact == null) {
      _editedContact = Contact();
      //SE VEIO PARA EDITAR
    } else {
      //PEGA O CONTATO
      _editedContact = Contact.fromMap(widget.contact.toMap());
      //COLOCA OS DADOS NOS CONTROLADORES
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    //QUANDO REALIZAR POP
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        //BARRA DO APP
        appBar: AppBar(
          backgroundColor: Colors.red,
          //NOME OU SE FOR VAZIO => "NOVO CONTATO"
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        //BOTAO SALVAR COM VALIDAÇÃO DO CAMPO NOME
        floatingActionButton: FloatingActionButton(
          //SE CLICADO
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          //TIPO DE ICON
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          //PADDING DE TODOS OS LADOS
          padding: EdgeInsets.all(10.0),
          //COLUNA
          child: Column(
            children: <Widget>[
              //IMAGEM CLICAVEL
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  //DECORATION DA IMAGEM
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    //SE NAO TIVER IMAGEM USA A IMAGEM PADRÃO
                    image: DecorationImage(
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage("images/person.png"),
                        fit: BoxFit.cover),
                  ),
                ),
                //SE CLICADO
                onTap: () {
                  //EXTENÇÃO ABRIR CAMERA E TIRAR FOTO
                  ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    //SE VOLTAR SEM TIRAR FOTO
                    if (file == null) return;
                    //ELSE PEGA A FOTO
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              //ENTRADA NOME
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              //ENTRADA EMAIL
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              //ENTRADA TELEFONE
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

//funcao que sera chamada apos acao de desempilhar
  Future<bool> _requestPop() {
    //IF SE FOI EDITADO
    if (_userEdited) {
      //SHOWDIALOG
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
