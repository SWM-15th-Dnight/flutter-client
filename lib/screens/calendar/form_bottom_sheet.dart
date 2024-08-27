import 'package:flutter/material.dart';

class FormBottomSheet extends StatelessWidget {
  const FormBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          color: Colors.yellow.withOpacity(0.3),
          child: ListView(
            controller: scrollController,
            children: [
              ListTile(
                title: Text('Schedule Registration'),
              ),
              // Add form input fields here
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MonthlyView extends StatelessWidget {
  const MonthlyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Monthly View'),
    );
  }
}
