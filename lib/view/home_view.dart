import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:srekn_fintra/view/transaction_details_view.dart';
import '/auth/phone_number_page.dart';

class HomeView extends StatefulWidget {
  final String uid;

  const HomeView({super.key, required this.uid});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late DatabaseReference _usersRef;
  late StreamSubscription _usersSubscription;
  Map<String, dynamic> _users = {};
  bool _isLoading = true;

  // Controllers for the new transaction fields
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersRef = FirebaseDatabase.instance.ref('users');
    _listenForUserData();
  }

  void _listenForUserData() {
    _usersSubscription = _usersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          _users = Map<String, dynamic>.from(event.snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _users = {};
        });
      }
    });
  }

  @override
  void dispose() {
    _usersSubscription.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> processTransactions(Map<String, dynamic> users) {
    final transactions = <Map<String, dynamic>>[];

    for (var userId in users.keys) {
      final user = users[userId];
      if (user['spend'] != null) {
        final spend = Map<String, dynamic>.from(user['spend']);
        spend.forEach((key, txn) {
          final txnData = Map<String, dynamic>.from(txn);
          transactions.add({
            'id': key,
            'userId': userId,
            'timestamp': txnData['timestamp'], // Add timestamp directly here
            'date': DateTime.fromMillisecondsSinceEpoch(txnData['timestamp'])
                .toLocal()
                .toString()
                .split(' ')[0],
            'remark': txnData['remark'],
            'amounts': {
              userId: (txnData['amount'] is int)
                  ? (txnData['amount'] as int).toDouble()
                  : txnData['amount']
            }
          });
        });
      }
    }

    // Sort transactions by timestamp (latest first)
    transactions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return transactions;
  }

  // Method to add a new transaction
  void _addNewTransaction(String userId) {
    final remark = _remarkController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (remark.isNotEmpty && amount != null && amount > 0) {
      final user = _users[userId];
      final spend = user['spend'] ?? {};
      final newTransactionId =
          't${spend.length + 1}'; // Get next transaction ID

      final newTransaction = {
        'amount': amount,
        'remark': remark,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _usersRef.child(userId).child('spend').update({
        newTransactionId: newTransaction,
      });

      // Clear input fields after adding
      _remarkController.clear();
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction added successfully')),
      );

      // Navigate to Home page
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid remark and amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_users.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No Users Found')),
      );
    }

    final transactions = processTransactions(_users);

    String lastDate = '';
    Map<String, double> userTotals = {};
    Map<String, Map<String, double>> dailyTotals = {};

    _users.forEach((userId, user) {
      userTotals[userId] = 0.0;
    });

    transactions.forEach((txn) {
      final date = txn['date'];
      if (!dailyTotals.containsKey(date)) {
        dailyTotals[date] = {};
        _users.forEach((userId, _) {
          dailyTotals[date]![userId] = 0.0;
        });
      }
      txn['amounts'].forEach((userId, amount) {
        userTotals[userId] = (userTotals[userId] ?? 0) + (amount as double);
        dailyTotals[date]![userId] =
            (dailyTotals[date]![userId] ?? 0) + (amount as double);
      });
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[400],
        title: const Text('SreKn Fintra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PhoneNumberPage(), // Navigate to LoginPage
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Overall Totals - moved to left
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Overall Totals',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 18,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  // Horizontal scrolling Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _users.keys.map((userId) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _users[userId]['name'], // User name
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rs ${userTotals[userId]!.toStringAsFixed(2)}', // User total
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Display Transactions with Daily Totals
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.black26),
                columns: [
                  const DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._users.keys.map((userId) {
                    return DataColumn(
                      label: Text(
                        _users[userId]['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ],
                rows: transactions.expand((txn) {
                  final date = txn['date'];
                  final row = _users.keys.map((userId) {
                    return txn['amounts'][userId]?.toString() ?? '0';
                  }).toList();

                  final dailyRow = DataRow(
                    color: MaterialStateProperty.all(Colors.white70),
                    cells: [
                      const DataCell(Text('Today Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red))),
                      const DataCell(Text('')),
                      ..._users.keys.map((userId) {
                        return DataCell(Text(
                            (dailyTotals[date]![userId] ?? 0)
                                .toStringAsFixed(2),
                            style: TextStyle(color: Colors.red)));
                      }).toList(),
                    ],
                  );

                  final transactionRow = DataRow(
                    color: MaterialStateProperty.all(
                      txn['id'] == transactions.last['id']
                          ? Colors.white
                          : (txn['id'].hashCode.isOdd
                              ? Colors.grey.shade100
                              : Colors.white),
                    ),
                    cells: [
                      DataCell(Text(date == lastDate ? '' : date,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Text(txn['remark']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsView(
                                transaction: txn,
                                transactionId: txn['id'],
                              ),
                            ),
                          );
                        },
                      ),
                      ...row.map((amount) => DataCell(Text(amount))).toList(),
                    ],
                  );

                  if (date != lastDate) {
                    lastDate = date;
                    return [dailyRow, transactionRow];
                  }
                  return [transactionRow];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add transaction
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add New Transaction'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _remarkController,
                      decoration: const InputDecoration(
                        labelText: 'Remark',
                      ),
                    ),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addNewTransaction(widget.uid);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
