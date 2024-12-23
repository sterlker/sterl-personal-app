import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginlogoutbasic/bar%20graph/bar_graph.dart';
import 'package:loginlogoutbasic/database/expense_database.dart';
import 'package:loginlogoutbasic/helper/helper_functions.dart';
import 'package:loginlogoutbasic/models/expense.dart';
import 'package:provider/provider.dart';

import '../components/my_list_tile.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read database on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    // load futures
    refreshData();

    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  // Open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input => expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Expense Name"),
            ),

            // user input => expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Expense Amount"),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),

          // save button
          _saveButton()
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    // pre-fill existing values into textfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input => expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            // user input => expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),

          // save button
          _editButton(expense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense?"),
        actions: [
          // cancel button
          _cancelButton(),

          // save button
          _deleteButton(expense.id),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // calculate num of months since first month
      int monthCount =
      calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //only display expenses for the current month
      List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();
      // return UI
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                // loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // amount total
                      Text('RM${snapshot.data!.toStringAsFixed(2)}'),

                      // month
                      Text(getCurrentMonthName()),
                    ],
                  );
                }
                // loading
                else {
                  return const Text("Loading...");
                }
              },
            ),
            centerTitle: true,
            /*
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: Icon(Icons.logout),
              )
            ],
             */
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                // Graph UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      // data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        // create list of monthly summary
                        List<double> monthlySummary =
                        List.generate(monthCount, (index) {
                          // calculate year-month considering startMonth & index
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;

                          // create key in format 'year-month'
                          String yearMonthKey = '$year-$month';

                          // return total for yearMonth or 0.0 if non-existent
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      }

                      // loading
                      else {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Expense list UI
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the index to show latest item first
                      int reversedIndex =
                          currentMonthExpenses.length - 1 - index;

                      // get individual expense
                      Expense individualExpense =
                      currentMonthExpenses[reversedIndex];

                      // return list tile UI
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  ),
                )
              ],
            ),
          ));
    });
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop box
        Navigator.pop(context);

        // clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // save button => create new expense
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the textfield to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          // save to database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          // refresh graph
          refreshData();

          // clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // edit button => edit existing expense
  Widget _editButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save as long as at least one textfield has been changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create a new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          // old expense id
          int existingId = expense.id;

          // save to database
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          // refresh graph
          refreshData();
        }
      },
      child: const Text("Save"),
    );
  }

  // delete button => deletes expense
  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);

        // delete expense from database
        await context.read<ExpenseDatabase>().deleteExpense(id);

        // refresh graph
        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}
