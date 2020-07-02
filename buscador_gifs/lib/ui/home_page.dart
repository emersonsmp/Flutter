import 'dart:async';
import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //STRING DA BARRA DE BUSCA
  String _search;

  int _offset = 0;

  //METODO QUE IRA RETORNAR UM DADO FUTURO
  Future<Map> _getGifs() async {
    http.Response response;

    //SE A STRING SEARCH ESTIVER VAZIA CHAMA A API PARA RETORNAR TOP20 GIFS
    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=wusbFwUExpkztfjeMr3QRimPUc4kd1J9&limit=20&rating=G");
    //ELSE VAI BUSCAR O QUE ESTA NA STRING SEARCH
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=wusbFwUExpkztfjeMr3QRimPUc4kd1J9&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");

    return json.decode(response.body);
  }

  //PARA PRINTAR NO TERMINAL
  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //BARRA DO APP CONTEM UM GIF
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      //CORPO ORGANIZACAO EM COLUNA
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            //SEARCH BAR
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              //AGUARDA O OK PARA SETAR
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                //FUTURE: FUNCAO_QUE_DEVE_AGURDAR()
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    //CARREGANDO (Circulo Girando)
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        //CRIA A GRADE DE GIFS
                        return _createGifTable(context, snapshot);
                  }
                }),
          ),
        ],
      ),
    );
  }

  //PARA CONTROLAR TAMANHO DE QUADROS
  //QUANDO FOR PESQUISADO ALGO, ULTIMO QUADRO VAI CONTER O BOTAO "+ VER MAIS"
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

//METODO QUE VAI RETORNAR O GIFT
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        //PADDING LATERAL
        padding: EdgeInsets.all(10.0),
        //PADDING ENTRE OS QUADROS
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        //VAI RECEBER A QUANTIDADE
        itemCount: _getCount(snapshot.data["data"]),
        //CONSTRUTOR GRIDVIEW
        itemBuilder: (context, index) {
          //VAI CAREGAR GIF, APÓS VAI APARECER "CARREGAR MAIS..."
          if (_search == null || index < snapshot.data["data"].length)
            //WIDGET CLICAVEL
            return GestureDetector(
              //FILHO: IMAGE QUE SURGE SUAVEMENTE
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]
                    ["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              //UM CLIQUE
              onTap: () {
                //EMPILHA PAGINA
                Navigator.push(
                  context,
                  //CHMANDO PAGINA E PASSANDO O DADO
                  MaterialPageRoute(
                    builder: (context) => GifPage(snapshot.data["data"][index]),
                  ),
                );
              },
              //CLIQUE LONGO
              onLongPress: () {
                //COMPARTILHAR APPS
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          //QUANDO ALGO É BUSCADO, ULTIMO QUADRO VAI RECEBER BOTAO
          else
            return Container(
              //WIDGET CLICAVEL
              child: GestureDetector(
                //COLUNA
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                //SE CLICADO CARREGA MAIS GIF
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
