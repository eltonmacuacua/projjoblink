class Trabalho {
  final String jobId;
  final String titulo;
  final String descricao;
  final String categoria;
  final String orcamento;
  final String dataCriacao;
  final String dataLimite;
  final String cidadaoId;
  final String prazo;
  final String status;
  final String localizacao;

  Trabalho ({
    required this.jobId,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.orcamento,
    required this.dataCriacao,
    required this.cidadaoId,
    required this.prazo,
    required this.status,
    required this.localizacao,
  });

  Map<String, dynamic> toMap(){
    return{
      'jobId' : jobId,
      'titulo' : titulo,
      'descricao' : descricao,
      'categoria' : categoria,
      'orcamento' : orcamento,
      'dataCriacao' : dataCriacao,
      'cidadaoId' : cidadaoId,
      'prazo' : prazo,
      'status' : status,
      'localizacao' : localizacao,
    };
  }

}