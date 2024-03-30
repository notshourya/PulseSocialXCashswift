import 'package:flutter/material.dart';
import 'package:pulse_social/screens/payments_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:flutter/material.dart';


class WalletHomePage extends StatefulWidget {
  @override
  _WalletHomePageState createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  double _accountBalance = 1423.50;

  void _loadMoneyDialog() {
    final TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Load Money', style: TextStyle(fontWeight: FontWeight.bold),),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter amount'),
            controller: _amountController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red),),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Load' , style: TextStyle(color: Colors.blue),),
              onPressed: () {
                setState(() {
                  _accountBalance += double.parse(_amountController.text);
                });
                Navigator.of(context).pop();
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
            setState(() {
              _accountBalance -= amount;
            });
          }
        ),
      ),
    );
  }

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CashSwift Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
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
                style: Theme.of(context).textTheme.headline4?.copyWith(fontWeight: FontWeight.bold),
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
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Divider(),
              
        
            ],
          ),
        ),
      ),
    );
  }
}
