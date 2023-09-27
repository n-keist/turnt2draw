extension DblExt on double {
  double ifLessThanOrEqualTo({required double constraint, required double orElse}) {
    if (this <= constraint) return orElse;
    return this;
  }
}
