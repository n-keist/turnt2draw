extension OptionalFnExt on Function? {
  T callOrElse<T>({required T orElse}) {
    if (this == null) return orElse;
    return this!.call();
  }
}
