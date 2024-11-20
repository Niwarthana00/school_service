import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditCardScreen extends StatefulWidget {
  @override
  _CreditCardScreenState createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  void _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user's ID
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create a new payment document in Firestore
        final paymentRef = FirebaseFirestore.instance
            .collection('payments')
            .doc(user.uid)
            .collection('transactions')
            .doc();
        await paymentRef.set({
          'cardHolderName': _cardHolderNameController.text,
          'cardNumber': _cardNumberController.text,
          'expiryDate': _expiryDateController.text,
          'cvv': _cvvController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the form fields
        _cardHolderNameController.clear();
        _cardNumberController.clear();
        _expiryDateController.clear();
        _cvvController.clear();

        // Show a success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with top design
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFC995E), Color(0xFFFFC09F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content over the background
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40), // Space for back button area

                    // Title text and back button in the same row
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 10), // Space between icon and text
                        Text(
                          "Add New Card",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter your card number to make payment",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30), // Space below the header

                    // Card Image only
                    Center(
                      child: Image.asset(
                        'assets/images/card.png', // Add your card logo image path here
                        height: 200, // Adjust height as needed
                        width: double.infinity, // Full width
                      ),
                    ),
                    SizedBox(height: 10),

                    // Cardholder Name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        controller: _cardHolderNameController,
                        decoration: InputDecoration(
                          labelText: "Cardholder Name",
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFC995E)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the cardholder name';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Card Number
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: "Card Number",
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFC995E)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: Image.asset(
                            'assets/images/master.png', // Add your card type image (MasterCard)
                            height: 24,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the card number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    // Expiry Date and CVV in the same row with increased spacing
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: TextFormField(
                              controller: _expiryDateController,
                              decoration: InputDecoration(
                                labelText: "Expiry Date (MM/YY)",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFFC995E)),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the expiry date';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFC995E)),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the CVV';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 44),

                    // Pay Button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFC995E), // Set background color to match the design
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: _submitPayment,
                        child: Text(
                          "Pay now",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}