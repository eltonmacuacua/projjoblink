class Proposta{
  final String proposalId;
  final String valor;
  final String descricao;
  final String dataProposta;
  final String status;
  final String cidadaoId;
  final String freelancerId;

  Proposta ({
    required this.proposalId,
    required this.valor,
    required this.descricao,
    required this.dataProposta,
    required this.status,
    required this.cidadaoId,
    required this.freelancerId,
  });

  Map<String, dynamic> toMap(){
    return{
      'proposalId' : proposalId,
      'valor' : valor,
      'descricao' : descricao,
      'dataProposta' : dataProposta,
      'status' : status,
      'cidadaoId' : cidadaoId,
      'freelancerId' : freelancerId,
    };
  }

  static Proposta fromMap(Map<String, dynamic> map){
    return Proposta(
      proposalId: map['proposalId'],
      valor: map['valor'],
      descricao: map['descricao'],
      dataProposta: map['dataProposta'],
      status: map['status'],
      cidadaoId: map['cidadaoId'],
      freelancerId: map['freelancerId'],
    );
  }
}