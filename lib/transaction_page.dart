import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:minhas_despesas_pessoais/number_formatter.dart';
import 'package:minhas_despesas_pessoais/validate_empty.dart';
import 'package:uuid/uuid.dart';

import 'transaction_dao.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final valueController = MoneyMaskedTextController();

  String? selectedCategory;
  var selectedDate = DateTime.now();

  Transaction? initialValue;

  TransactionType? get type => initialValue?.type;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (initialValue == null && arguments is Transaction) {
      initialValue = arguments;

      final category = initialValue?.category ?? '';
      final value = initialValue?.value ?? 0.0;

      nameController.text = initialValue?.name ?? '';
      selectedDate = initialValue?.date ?? DateTime.now();
      dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      valueController.text = formatToCurrency(value);
      selectedCategory = category.isEmpty ? null : category;
    }
  }

  void add(BuildContext context) {
    // Processar e adicionar a renda à sua lista de transações aqui
    final name = nameController.text;

    final formState = Form.of(context);

    if (!formState.validate()) {
      return;
    }

    final value = valueController.numberValue;

    final transaction = Transaction(
      id: initialValue?.id ?? const Uuid().v4(),
      type: type!,
      value: value,
      name: name,
      date: selectedDate,
      category: selectedCategory!,
    );

    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adicionar Despesa',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  // Adicione campos para nome, data e valor da renda aqui
                  TextFormField(
                    validator: validateEmpty,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  TextFormField(
                    validator: validateEmpty,
                    controller: dateController,

                    decoration: const InputDecoration(
                      labelText: 'Data',
                      hintText: 'dd/MM/yyyy',
                    ),
                    keyboardType: TextInputType.datetime, // Usar um teclado específico para datas
                    onTap: () async {
                      // Exibir o seletor de data ao tocar no campo de data
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      }
                    },
                  ),
                  TextFormField(
                    validator: validateEmpty,
                    controller: valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    validator: validateEmpty,
                    hint: const Text('Categoria'),
                    items: ['Renda', 'Alimentação', 'Transporte', 'Saúde', 'Educação', 'Lazer', 'Vestuário', 'Telefones/Internet', 'Outros', 'Bancos']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    value: selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => add(context),
                        child: const Text('Adicionar'),
                      ),
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('Cancelar'),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
