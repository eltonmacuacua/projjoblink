class Mensagem {
  final String mensagemId;
  final String conteudo;
  final String dataEnvio;
  final String lida;
  final String cidadaoId;
  final String freelancerId;

  Mensagem({
    required this.mensagemId,
    required this.conteudo,
    required this.dataEnvio,
    required this.lida,
    required this.cidadaoId,
    required this.freelancerId,
  });

  Map<String, dynamic> toMap(){
    return{
      'mensagemId' : mensagemId, 
      'conteudo' : conteudo, 
      'dataEnvio' : dataEnvio, 
      'lida' : lida, 
      'cidadaoId' : cidadaoId, 
      'freelancerId' : freelancerId, 
    };
  }

  static Mensagem fromMap(Map<String, dynamic> map){
    return Mensagem(
      mensagemId: map['mensagemId'],
      conteudo: map['conteudo'],
      dataEnvio: map['dataEnvio'],
      lida: map['lida'],
      cidadaoId: map['cidadaoId'],
      freelancerId: map['freelancerId'],
    );
  }


}