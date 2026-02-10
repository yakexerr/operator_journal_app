import 'package:flutter/material.dart';

class DarsiVeisbah extends StatefulWidget {
  const DarsiVeisbah({super.key});

  @override
  State<DarsiVeisbah> createState() => _DarsiVeisbahState();
}

/*
Формула потерь давления из-за трения жидкости о стенки трубы
ΔP=λ*(L/D)*(rho*v**2)/2
L
D
(rho*v**2)/2 - динамическое давление - кинетическия энергия потока на единицу объёма
λ - коэффициент гидравлического сопротивления

*/

class _DarsiVeisbahState extends State<DarsiVeisbah> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}