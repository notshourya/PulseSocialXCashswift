import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulse_social/utility/colors.dart';

class PaymentScreen extends StatefulWidget {
  final double accountBalance;
  final Function(double amount) onPaymentMade;

  PaymentScreen({required this.accountBalance, required this.onPaymentMade});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedUserUPI = '';
  final TextEditingController _amountController = TextEditingController();
  List<Map<String, dynamic>> _followersDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    setState(() {
      _isLoading = true;
    });

    User? currentUser = _auth.currentUser;
    var userData =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    List<dynamic> following = userData.data()?['following'] ?? [];

    List<Map<String, dynamic>> followersDetailsTemp = [];
    for (String userId in following) {
      var userSnapshot = await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        followersDetailsTemp.add({
          'username': userSnapshot.data()?['username'],
          'upiId': '${userSnapshot.data()?['username']}@cashswift',
          'photoUrl': userSnapshot.data()?['photoUrl'],
        });
      }
    }

    setState(() {
      _followersDetails = followersDetailsTemp;
      _isLoading = false;
    });
  }

  void _makePayment() async {
    double amount = double.tryParse(_amountController.text) ?? 0;
    String followerName = _followersDetails.firstWhere(
      (follower) => follower['upiId'] == _selectedUserUPI,
      orElse: () => {'username': 'Unknown'},
    )['username'];

    if (amount > 0 &&
        widget.accountBalance >= amount &&
        _selectedUserUPI.isNotEmpty) {
      widget.onPaymentMade(amount);

      await FirebaseFirestore.instance.collection('transactions').add({
        'uid': _auth.currentUser!.uid,
        'upiId': _auth.currentUser!.email!.split('@')[0] + '@cashswift',
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'description': 'Payment of ₹$amount successful to $followerName',
        'category': 'Transfer',
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment of ₹$amount successful to $followerName',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient funds to make payment.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: Text(
          'Make a Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a Follower:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _followersDetails.length,
                      itemBuilder: (context, index) {
                        final follower = _followersDetails[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUserUPI = follower['upiId'];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedUserUPI == follower['upiId']
                                    ? Color.fromARGB(255, 32, 31, 31)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(follower['photoUrl']),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          follower['username'],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          follower['upiId'],
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedUserUPI == follower['upiId'])
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _makePayment,
                      child: Text(
                        'Pay',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
