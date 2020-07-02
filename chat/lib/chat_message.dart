import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  //CONTRUTOR DA CLASSE, SALVA SEUS PARAMETROS RECEBIDOS NAS VARIAVEIS INDICADAS POR THIS
  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          // #region FALSE - NÃO É MINHA MENSAGEM
          //IMAGEM DO AVATAR A DIREITA
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      data['senderphotourl'],
                    ),
                  ),
                )
              : Container(),
          // #endregion

          //TEXTO OU IMAGEM DA MENSAGEM
          Expanded(
            child: Column(
              crossAxisAlignment:
                  //É MINHA MESAGEM? ALINHE AO FINAL : ALINHE NO INICIO
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                //MENSAGEM POSSUI UMA IMAGEM ?:
                data['imgurl'] != null
                    ? Image.network(
                        data['imgurl'],
                        width: 250,
                      )
                    //MENSAGEM NÃO POSSUI UMA IMAGEM, E SIM TEXTO
                    : Text(
                        data['text'],
                        //ALINHAMENTO ESQ OU DIR
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                //NOME DE QUEM ENVIOU A MENSAGEM
                Text(
                  data['senderName'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // #region É A MINHA MENSAGEM: INSIRA MEU AVATAR A ESQ
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      data['senderphotourl'],
                    ),
                  ),
                )
              : Container(),
          // #endregion
        ],
      ),
    );
  }
}
