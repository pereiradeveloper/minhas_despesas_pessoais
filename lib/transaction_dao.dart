import 'package:drift/drift.dart';
import 'package:minhas_despesas_pessoais/database.dart';
import 'package:minhas_despesas_pessoais/main.dart';

part 'transaction_dao.g.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction implements Insertable<Transaction> {
  final String id;
  final double value;
  final String name;
  final DateTime date;
  final TransactionType type;
  final String category;

  Transaction({
    required this.id,
    required this.value,
    required this.name,
    required this.date,
    required this.type,
    required this.category,
  });

  Month get month => Month.valueOf(date.month);
  int get year => date.year;

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      name: Value(name),
      value: Value(value),
      date: Value(date),
      type: Value(type),
      category: Value(category),
    ).toColumns(nullToAbsent);
  }
}

@UseRowClass(Transaction)
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get category => text()();
  RealColumn get value => real()();
}

abstract class TransactionDao {
  Stream<List<Transaction>> findAllByMonthAndYear(int month, int year);

  Stream<List<Transaction>> findAllOrderByValue();

  Future<void> saveOrReplace(Transaction item);

  Future<void> deleteById(String id);
}

@DriftAccessor(tables: [Transactions])
class TransactionDaoimpl extends DatabaseAccessor<AppDatabase> with _$TransactionDaoimplMixin implements TransactionDao {
  TransactionDaoimpl(AppDatabase db) : super(db);

  @override
  Stream<List<Transaction>> findAllByMonthAndYear(int month, int year) {
    return (select(transactions)
          ..where((tx) => tx.date.month.equals(month) & tx.date.year.equals(year))
          ..orderBy(
            [
              (u) => OrderingTerm(expression: u.date, mode: OrderingMode.desc),
            ],
          ))
        .watch();
  }

  @override
  Stream<List<Transaction>> findAllOrderByValue() {
    return (select(transactions)
          ..orderBy(
            [
              (u) => OrderingTerm(expression: u.value, mode: OrderingMode.desc),
            ],
          ))
        .watch();
  }

  @override
  Future<void> saveOrReplace(Transaction item) async {
    await into(transactions).insert(item, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> deleteById(String id) async {
    await (delete(transactions)..where((transaction) => transaction.id.equals(id))).go();
  }
}
