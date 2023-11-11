import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minhas_despesas_pessoais/main.dart';
import 'package:minhas_despesas_pessoais/number_formatter.dart';

import 'transaction_dao.dart';

class TransactionListScreen extends StatefulWidget {
  final List<Transaction> initialTransactions;
  final Month initialMonth;
  final int initialYear;
  final double saldoPrevisto;

  const TransactionListScreen({
    super.key,
    required this.initialTransactions,
    required this.initialMonth,
    required this.initialYear,
    required this.saldoPrevisto,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  Month selectedMonth = Month.january;
  int selectedYear = 2023;
  bool _showLargestTransactions = false;

  List<Transaction> _getSortedTransactions() {
    final sortedTransactions = List.of(widget.initialTransactions);
    sortedTransactions.sort((a, b) {
      if (_showLargestTransactions) {
        return b.value.compareTo(a.value);
      } else {
        return b.date.compareTo(a.date);
      }
    });

    return sortedTransactions.where((transaction) {
      return transaction.month == selectedMonth && transaction.year == selectedYear;
    }).toList();
  }

  void _handleMonthChanged(Month? newValue) {
    if (newValue != null) {
      setState(() {
        selectedMonth = newValue;
      });
    }
  }

  void _handleYearChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        selectedYear = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final saldoPrevisto = widget.saldoPrevisto;
    final sortedTransactions = _getSortedTransactions();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Transações",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
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
                    Color.fromARGB(255, 158, 172, 90),
                    Color.fromARGB(255, 151, 165, 83),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(500, 30),
                  bottomRight: Radius.elliptical(500, 30),
                ),
              ),
              height: 287,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Container(
                padding: const EdgeInsets.only(left: 130),
                child: Row(
                  children: [
                    DropdownButton(
                      value: selectedMonth,
                      onChanged: _handleMonthChanged,
                      items: Month.values.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                    ),
                    DropdownButton(
                      value: selectedYear, // Use o valor passado como parâmetro
                      onChanged: (int? newValue) {
                        setState(() {
                          _showLargestTransactions = false;
                          _handleYearChanged(newValue);
                          // Chame a função para atualizar o ano na tela principal
                        });
                      },
                      items: [
                        2022,
                        2023,
                      ].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.white,
              ),
              width: 358,
              height: 500,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Balanço Total',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'R\$$saldoPrevisto',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: const Color(0xFF222222),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    endIndent: 20,
                    indent: 20,
                    thickness: 0.4,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: 20,
            right: 0,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLargestTransactions = true;
                    });
                  },
                  child: Container(
                    width: 160,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _showLargestTransactions ? const Color.fromARGB(255, 151, 165, 83) : Colors.black.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        'Maiores Transações',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _showLargestTransactions ? Colors.white : const Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLargestTransactions = false;
                    });
                  },
                  child: Container(
                    width: 160,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: !_showLargestTransactions ? const Color.fromARGB(255, 151, 165, 83) : Colors.black.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        'Transações Recentes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: !_showLargestTransactions ? Colors.white : const Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLargestTransactions)
            Positioned(
              top: 300,
              left: 20,
              right: 20,
              bottom: 0,
              child: ListView.builder(
                itemCount: sortedTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = sortedTransactions[index];
                  final textColor = transaction.type == TransactionType.income ? Colors.green : Colors.red;
                  final signal = transaction.type == TransactionType.income ? '+' : '-';
                  return ListTile(
                    title: Text(
                      transaction.name,
                      style: GoogleFonts.inter(
                          color: const Color(
                            0xFF000000,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: const Icon(Icons.attach_money),
                    subtitle: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                    ),
                    trailing: Column(
                      children: [
                        Text(
                          '$signal${formatToCurrency(transaction.value)}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    // Outros detalhes da transação, como renda e despesas, podem ser exibidos aqui
                  );
                },
              ),
            )
          else
            Positioned(
              top: 300,
              left: 20,
              right: 20,
              bottom: 0,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = sortedTransactions[index];
                        final textColor = transaction.type == TransactionType.income ? Colors.green : Colors.red;
                        final signal = transaction.type == TransactionType.income ? '+' : '-';
                        return ListTile(
                          title: Text(
                            transaction.name,
                            style: GoogleFonts.inter(
                                color: const Color(
                                  0xFF000000,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          leading: const Icon(Icons.attach_money),
                          subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
                          // Outros detalhes da transação, como renda e despesas, podem ser exibidos aqui
                          trailing: Text(
                            '$signal${formatToCurrency(transaction.value)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
