import 'package:flutter/material.dart';

class ParentStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFC995E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back when the back arrow is pressed
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Student status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFFC995E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Text(
                'Live Status Updates\nChild\'s Journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineItem(
                    context,
                    isCompleted: true,
                    title: 'Pickup from home',
                    description: 'Your child has been picked up from home.',
                  ),
                  _buildTimelineItem(
                    context,
                    isCompleted: true,
                    title: 'At school',
                    description: 'Your child has arrived at school.',
                  ),
                  _buildTimelineItem(
                    context,
                    isCompleted: false,
                    title: 'Pickup from school',
                    description: 'Your child has been picked up from school.',
                  ),
                  _buildTimelineItem(
                    context,
                    isCompleted: false,
                    title: 'Drop',
                    description: 'Your child has been dropped off at home.',
                  ),
                ],
              ),
            ),
          ),
          // Card with profile photo and details
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Color(0xFFFED2B7), // Set the background color as requested
                borderRadius: BorderRadius.circular(30), // Curved border
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niwarthana Sathyanjali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'At school',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Updated "Stay updated" text inside the card and smaller
                  Text(
                    'Stay updated on your child\'s journey to and from school.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13, // Smaller font size
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, {
        required bool isCompleted,
        required String title,
        required String description,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Color(0xFFFC995E) : Colors.grey[300],
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            Container(
              height: 50,
              width: 2,
              color: isCompleted ? Color(0xFFFC995E) : Colors.grey[300],
            ),
          ],
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
