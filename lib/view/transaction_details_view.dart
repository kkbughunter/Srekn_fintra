import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TransactionDetailsView extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final String transactionId;

  const TransactionDetailsView({
    super.key,
    required this.transaction,
    required this.transactionId,
  });

  @override
  _TransactionDetailsViewState createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  late TextEditingController _remarkController;
  late Map<String, TextEditingController> _amountControllers;

  @override
  void initState() {
    super.initState();

    _remarkController =
        TextEditingController(text: widget.transaction['remark'] ?? '');
    _amountControllers = {};
    widget.transaction['amounts'].forEach((userId, amount) {
      _amountControllers[userId] = TextEditingController(
        text: amount.toString(),
      );
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _amountControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    final updatedAmounts = _amountControllers.map((userId, controller) {
      return MapEntry(userId, double.tryParse(controller.text) ?? 0.0);
    });
    final DatabaseReference ref = FirebaseDatabase.instance.ref(
        'users/${widget.transaction['userId']}/spend/${widget.transactionId}');

    await ref.update({
      'remark': _remarkController.text,
      'amount': updatedAmounts[widget.transaction['userId']] ?? 0.0,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Transaction Updated')));
    Navigator.pop(context, true);
  }

  Future<void> _deleteTransaction() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref(
        'users/${widget.transaction['userId']}/spend/${widget.transactionId}');
    await ref.remove();
    Navigator.pop(context);
  }

  Future<void> _confirmDeleteTransaction() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        // backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${widget.transaction['date']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: 'Remark',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              const Text(
                'Amounts:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ..._amountControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Rs",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: entry.value,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _confirmDeleteTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
