import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loginlogoutbasic/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  // Setup
  // Initialize Database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // Getters

  List<Expense> get allExpense => _allExpenses;

  // Operations
  // Create
  Future<void> createNewExpense(Expense newExpense) async {
    // Add to database
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // Re-read from database
    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // Give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // Update UI
    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // Ensures new expense has same id as existing
    updatedExpense.id = id;

    // Update in database
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // Re-read from database
    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async {
    // Delete from database
    await isar.writeTxn(() => isar.expenses.delete(id));

    // Re-read from database
    await readExpenses();
  }

  // Helpers
  // calculate total expense for each month
  Future<Map<String, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the database
    await readExpenses();

    // create a map to keep track of total expenses per month, year
    Map<String, double> monthlyTotals = {

    };

    // iterate over all expenses
    for(var expense in _allExpenses){
      // extract the year & month from the date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      // if year & month is not yet on the map, initialize to 0
      if(!monthlyTotals.containsKey(yearMonth)){
        monthlyTotals[yearMonth] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async{
    // ensure expenses are read from database first
    await readExpenses();

    // get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // filter the expense to include only those for this month and this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense){
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    // calculate total amount for the current month
    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // get start month
  int getStartMonth() {
    if(_allExpenses.isEmpty){
      return DateTime.now().month; // defaults to current month if no expenses are recorded
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if(_allExpenses.isEmpty){
      return DateTime.now().year; // defaults to current year if no expenses are recorded
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
