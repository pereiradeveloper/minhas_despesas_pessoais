import 'package:intl/intl.dart';

final numberFormat = NumberFormat.currency(locale: 'pt-Br', name: '', symbol: '');

String formatToCurrency(double value) {
  return numberFormat.format(value);
}
