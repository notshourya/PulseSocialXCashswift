
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category {
  food,
  transportation,
  housing,
  utilities,
  clothing,
  health,
  insurance,
  personal,
  debt,
  education,
  entertainment,
  miscellaneous
}

const categoryToString = {
  Category.food: 'food',
  Category.transportation: 'transportation',
  Category.housing: 'housing',
  Category.utilities: 'utilities',
  Category.clothing: 'clothing',
  Category.health: 'health',
  Category.insurance: 'insurance',
  Category.personal: 'personal',
  Category.debt: 'debt',
  Category.education: 'education',
  Category.entertainment: 'entertainment',
  Category.miscellaneous: 'miscellaneous',
};

const categoryIcons = {
  'food': Icons.fastfood,
  'transportation': Icons.flight_takeoff,
  'housing': Icons.home,
  'utilities': Icons.work,
  'clothing': Icons.shopping_bag,
  'health': Icons.accessibility,
  'insurance': Icons.security,
  'personal': Icons.person,
  'debt': Icons.money_off,
  'education': Icons.school,
  'entertainment': Icons.movie,
  'miscellaneous': Icons.more_horiz_outlined,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();
  
  final String title;
  final double amount;
  final String id;
  final DateTime date;
  final Category category; // Change the type to Category enum

  String get formattedDate {
    return formatter.format(date);
  }
}


class ExpenseBucket{
  const ExpenseBucket({required this.category,required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category) :
  expenses = allExpenses.where((expense) => expense.category == category).toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses{
    double sum = 0;

    for(final expense in expenses){
      sum += expense.amount;
    }

    return sum;
  }
}