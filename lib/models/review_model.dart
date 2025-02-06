class Avaliacao {
  final String reviewId;
  final String cidadaoId;
  final String freelancerId;
  final String trabalhoId;
  final String comentario;
  final String nota;
  final String dataCriacao;

  Avaliacao({
    required this.reviewId,
    required this.cidadaoId,
    required this.freelancerId,
    required this.trabalhoId,
    required this.comentario,
    required this.nota,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap(){
    return{
      'reviewId' : reviewId,
      'cidadaoId' : cidadaoId,
      'freelancerId' : freelancerId,
      'trabalhoId' : trabalhoId,
      'comentario' : comentario,
      'nota' : nota,
      'dataCriacao' : dataCriacao,
    };
  }

  static Avaliacao fromMap(Map<String, dynamic> map){
    return Avaliacao(
      reviewId: map['reviewId'],
      cidadaoId: map['cidadaoId'],
      freelancerId: map['freelancerId'],
      trabalhoId: map['trabalhoId'],
      comentario: map['comentario'],
      nota: map['nota'],
      dataCriacao: map['dataCriacao'],
    );
  }
}