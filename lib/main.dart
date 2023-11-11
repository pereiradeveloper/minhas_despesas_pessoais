import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minhas_despesas_pessoais/abc.dart';
import 'package:minhas_despesas_pessoais/database.dart';
import 'package:minhas_despesas_pessoais/number_formatter.dart';
import 'package:minhas_despesas_pessoais/transaction_dao.dart';
import 'package:minhas_despesas_pessoais/transaction_list.dart';
import 'package:minhas_despesas_pessoais/transaction_page.dart';
import 'package:uuid/uuid.dart';

// Importe a biblioteca para formatar datas

enum Month {
  january(1, 'Janeiro'),
  february(2, 'Fevereiro'),
  march(3, 'Março'),
  april(4, 'Abril'),
  may(5, 'Maio'),
  june(6, 'Junho'),
  july(7, 'Julho'),
  august(8, 'Agosto'),
  september(9, 'Setembro'),
  october(10, 'Outubro'),
  november(11, 'Novembro'),
  december(12, 'Dezembro');

  final int number;
  final String name;

  const Month(this.number, this.name);

  static Month valueOf(int value) => Month.values.firstWhere((element) => element.number == value);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(),
        "/transaction": (context) => const TransactionPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = AppDatabase();
  int _currentIndex = 0;
  var selectedMonth = Month.january;
  int selectedYear = 2023;
  bool _isExpanded = false;
  List<Transaction> filteredTransactions = [];
  StreamSubscription? subscription;

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double saldoPrevisto = 0.0;

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();

    selectedMonth = Month.valueOf(currentDate.month);
    selectedYear = currentDate.year;

    // Inicialmente, exibe todas as transações
    updateFilteredTransactions();
  }

  void updateFilteredTransactions() {
    subscription?.cancel();
    final stream = db.transactionDaoimpl.findAllByMonthAndYear(selectedMonth.number, selectedYear);
    subscription = stream.listen((event) {
      // Calcula o total de renda e despesas
      filteredTransactions = event;
      totalIncome = filteredTransactions.where((element) => element.type == TransactionType.income).fold(0.0, (sum, transaction) => sum + transaction.value);
      totalExpenses = filteredTransactions.where((element) => element.type == TransactionType.expense).fold(0.0, (sum, transaction) => sum + transaction.value);
      saldoPrevisto = totalIncome - totalExpenses;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void createTransaction(TransactionType type) {
    final newValue = Transaction(
      id: const Uuid().v4(),
      value: 0,
      name: '',
      date: DateTime.now(),
      type: type,
      category: '',
    );

    goToTransaction(newValue);
  }

  void editTransaction(int index, Transaction transaction) {
    goToTransaction(transaction);
  }

  void goToTransaction(Transaction transaction) async {
    final result = await Navigator.of(context).pushNamed("/transaction", arguments: transaction);

    if (result is! Transaction) {
      return;
    }

    await db.transactionDaoimpl.saveOrReplace(result);

    updateFilteredTransactions();
    _isExpanded = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) async {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 96, 106, 52),
            icon: Icon(Icons.home),
            label: '',
            activeIcon: Icon(
              Icons.home,
              color: Color.fromARGB(255, 96, 106, 52),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
            activeIcon: Icon(
              Icons.list,
              color: Color.fromARGB(255, 96, 106, 52),
            ),
          )
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: _isExpanded ? Alignment.center : Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isExpanded) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  heroTag: 'tab_renda',
                  backgroundColor: Colors.green,
                  onPressed: () => createTransaction(TransactionType.income),
                  tooltip: 'Renda',
                  child: const Icon(Icons.trending_up),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  heroTag: 'tab_despesa',
                  backgroundColor: Colors.red,
                  onPressed: () => createTransaction(TransactionType.expense),
                  tooltip: 'Despesa',
                  child: const Icon(Icons.trending_down_sharp),
                ),
              ),
              const SizedBox(height: 5),
            ],
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 96, 106, 52),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Icon(_isExpanded ? Icons.close : Icons.add),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color.fromARGB(255, 202, 219, 113),
                          Color.fromARGB(255, 96, 106, 52),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(500, 30),
                        bottomRight: Radius.elliptical(500, 30),
                      ),
                    ),
                    height: 307,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          DropdownButton(
                            value: selectedMonth,
                            onChanged: (newValue) {
                              setState(() {
                                selectedMonth = newValue!;
                                updateFilteredTransactions();
                              });
                            },
                            items: Month.values.map(
                              (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value.name),
                                );
                              },
                            ).toList(),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<int>(
                            value: selectedYear,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedYear = newValue!;
                                updateFilteredTransactions();
                              });
                            },
                            items: <int>[
                              2022,
                              2023,
                              2024,
                              2025,
                              2026,
                            ].map(
                              (value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      margin: const EdgeInsets.only(right: 20, left: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 96, 106, 52),
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saldo Previsto',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  Text(
                                    'R\$${formatToCurrency(saldoPrevisto)}',
                                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Container(
                                    padding: const EdgeInsets.only(right: 80),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Renda',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFD0E5E4),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          formatToCurrency(totalIncome),
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(16.0),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.trending_down,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Despesas',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFFD0E5E4),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formatToCurrency(totalExpenses),
                                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (filteredTransactions.length > 5) PieChartWidget(transactions: filteredTransactions),
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Histórico De Transações',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Ver todos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = filteredTransactions[index];
                            final textColor = item.type == TransactionType.income ? Colors.green : Colors.red;
                            final signal = item.type == TransactionType.income ? "+" : "-";
                            return ListTile(
                              leading: const Icon(Icons.attach_money),
                              onTap: () => editTransaction(index, item),
                              title: Text(
                                item.name,
                                style: GoogleFonts.inter(
                                    color: const Color(
                                      0xFF000000,
                                    ),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(item.date)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$signal${formatToCurrency(item.value)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    splashRadius: 22,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(item),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          TransactionListScreen(
            initialTransactions: filteredTransactions,
            saldoPrevisto: saldoPrevisto,
            initialMonth: selectedMonth,
            initialYear: selectedYear,
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(Transaction item) async {
    final txDao = db.transactionDaoimpl;
    await db.transactionDaoimpl.deleteById(item.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('transação excluída com sucesso'),
        action: SnackBarAction(
          label: 'desfazer',
          onPressed: () async {
            txDao.saveOrReplace(item);
          },
        ),
      ),
    );
  }
}
