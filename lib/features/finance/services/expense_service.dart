import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final CollectionReference _expensesRef = FirebaseFirestore.instance.collection('expenses');

  Stream<List<ExpenseModel>> getAllExpenses() {
    return _expensesRef.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addExpense(ExpenseModel expense) {
    return _expensesRef.add(expense.toMap());
  }

  Future<void> deleteExpense(String id) {
    return _expensesRef.doc(id).delete();
  }
}