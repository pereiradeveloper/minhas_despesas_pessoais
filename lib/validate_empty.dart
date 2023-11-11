String? validateEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'Digite um valor válido';
  }
  return null;
}
