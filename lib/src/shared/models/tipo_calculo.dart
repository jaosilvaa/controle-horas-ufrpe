enum TipoCalculo {
  porSemestre,
  porCargaHoraria;

  String get label => switch (this) {
        TipoCalculo.porSemestre => 'Por semestre',
        TipoCalculo.porCargaHoraria => 'Por carga horária',
      };
}
