/// Tipo de atendimento oferecido pela rede de saúde.
enum TipoAtendimento {
  consulta('Consulta Médica', 'Especialidade', 'Consulta'),
  exame('Exame Laboratorial', 'Exame', 'Exame'),
  vacinacao('Vacinação', 'Vacina', 'Vacinação'),
  receita('Renovação de Receita', 'Serviço', 'Receita');

  const TipoAtendimento(this.rotulo, this.rotuloServico, this.rotuloCurto);

  /// Nome completo exibido ao usuário.
  final String rotulo;

  /// Título da etapa "especialidade/serviço" para este tipo.
  final String rotuloServico;

  /// Nome curto, usado em chips e tags.
  final String rotuloCurto;
}
