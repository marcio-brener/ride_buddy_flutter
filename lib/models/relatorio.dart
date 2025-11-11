class Relatorio {
  final double totalReceitas;
  final double totalDespesas;
  final double meta;
  final double lucroLiquido;
  final double progresso; 
  final double metaRestante;

  Relatorio({
    required this.totalReceitas,
    required this.totalDespesas,
    required this.meta,
  })  : lucroLiquido = totalReceitas - totalDespesas,
        progresso = (meta > 0 ? (totalReceitas - totalDespesas) / meta : 0.0).clamp(0.0, 1.0),
        metaRestante = (meta - (totalReceitas - totalDespesas)).clamp(0.0, meta);
  
  factory Relatorio.vazio() {
    return Relatorio(totalReceitas: 0, totalDespesas: 0, meta: 0);
  }
}