import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//VARIAVEL PARA VERIFICAR SE TEM TEXTO NA CAIXA DE ENTRADA
bool _isComposing = false;

class TextComposer extends StatefulWidget {
  //Declaração de uma função dinamica
  Function({String text, File imgFile}) sendMessage;
  //CONSTRUCTOR
  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();

  //Limpa controlador de texto e apaga botão de enviar
  void Reset() {
    _controller.clear();

    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final File imgFile =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              if (imgFile == null) return;

              widget.sendMessage(imgFile: imgFile);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              //SE HOUVER MUDANÇA => TEXT.POSSUI_TEXTO ? _ISCOMING = TRUE;
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                Reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            //SE _ISCOMPOSING FOR TRUE ATIVA BOTÃO
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    Reset();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
