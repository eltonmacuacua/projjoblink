class Usuario{
  final String userid;
  final String nome;
  final String email;
  final String senha;
  final String telefone;
  final String tipoDeUsuario;
  final String especializacao;
  final String dataCadastro;
  final String localizacao;

  Usuario({
    required this.userid,
    required this.nome,
    required this.email,
    required this.senha,
    required this.telefone,
    required this.tipoDeUsuario,
    required this.especializacao,
    required this.dataCadastro,
    required this.localizacao,
  });

  Map<String, dynamic> toMap(){
    return {
      'userid' : userid,
      'nome' : nome,
      'email' : email,
      'senha' : senha,
      'telefone' : telefone,
      'tipoDeUsuario' : tipoDeUsuario,
      'especializacao' : especializacao,
      'dataCadastro' : dataCadastro,
      'localizacao' : localizacaom
    };
  }
}