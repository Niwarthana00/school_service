import 'package:flutter/material.dart';
import 'credit_card.dart'; // Import the CreditCardScreen

class ParentPayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Add image above the Make a Payment button
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Image.asset(
              'assets/images/payment.png', // Make sure the path is correct
              height: 100, // Adjust the size as per the requirement
            ),
          ),

          // Make a Payment Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFC995E), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Remove rounded corners
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Navigate to the CreditCardScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreditCardScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, color: Colors.white), // White icon color
                  SizedBox(width: 8),
                  Text(
                    'Make a payment',
                    style: TextStyle(
                      color: Colors.white, // White text color
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Payment items
                paymentTile(context, "January"),
                paymentTile(context, "February"),
                paymentTile(context, "March"),
                paymentTile(context, "April"),
                paymentTile(context, "April"),
                paymentTile(context, "January"),
                paymentTile(context, "February"),
                paymentTile(context, "March"),
                paymentTile(context, "April"),
                paymentTile(context, "April"), // Duplicate for demo purpose
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to create each payment tile
  Widget paymentTile(BuildContext context, String month) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dismissible(
        key: Key(month),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          // Show a dialog to confirm deletion
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Confirm Deletion"),
              content: Text("Are you sure you want to delete the payment for $month?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Here you can perform the deletion action
                    Navigator.of(context).pop(true); // Confirm
                  },
                  child: Text("Delete"),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          // Handle the deletion logic here
          // For example, you might want to remove the item from a list
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF1ECEC), // Card background color #F3F2F8
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Color(0xFFFC995E)),
            title: Text('You paid for $month'),
            subtitle: Text('Payment has been successfully received.'),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParentPayment(),
  ));
}
