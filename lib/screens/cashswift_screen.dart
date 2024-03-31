import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_social/screens/payments_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletHomePage extends StatefulWidget {
  @override
  _WalletHomePageState createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  double _accountBalance = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserBalance();
  }

  Future<void> fetchUserBalance() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        _accountBalance = userData.data()?['accountBalance']?.toDouble() ?? 0.0;
      });
    }
  }

  void updateAccountBalance(double amount) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      double newBalance = _accountBalance + amount;
      if (newBalance >= 0) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'accountBalance': newBalance,
        }).then((value) => fetchUserBalance());
      }
    }
  }

  void _loadMoneyDialog() {
    final TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Load Money',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter amount'),
            controller: _amountController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Load', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                double amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  updateAccountBalance(amount);
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Please enter a valid amount greater than zero.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToPaymentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
            accountBalance: _accountBalance,
            onPaymentMade: (double amount) {
              updateAccountBalance(-amount); 
            }),
      ),
    );
  }

  Widget buildTransactionHistory() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No transactions yet.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var transaction = snapshot.data!.docs[index];
            return ListTile(
              leading: Icon(
                transaction['type'] == 'credit'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction['type'] == 'credit'
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(transaction['description']),
              subtitle: Text(
                DateFormat.yMMMd().add_jm().format(
                    (transaction['timestamp'] as Timestamp).toDate()),
              ),
              trailing: Text(
                '₹${transaction['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction['type'] == 'credit'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CashSwift Wallet',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30)),
        backgroundColor: mobileBackgroundcolor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 10),
              Text(
                '₹${_accountBalance.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 5),
              Wrap(
                spacing: 10,
                children: [
                  ActionChip(
                    avatar: Icon(Icons.add, color: Colors.white),
                    label: Text('Load Money'),
                    onPressed: _loadMoneyDialog,
                    backgroundColor: Colors.blue,
                  ),
                  ActionChip(
                    avatar: Icon(Icons.send, color: Colors.white),
                    label: Text('Send Money'),
                    onPressed: _navigateToPaymentScreen,
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Transactions',
                  style: Theme.of(context).textTheme.subtitle1),
              Divider(),
              Container(
                height: 200,
                child: buildTransactionHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
