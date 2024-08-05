import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final FocusNode _focusnode = FocusNode();

    return GestureDetector(
      onTap: () {
        _focusnode.unfocus();
      },
      child: Scaffold(
          body: Scaffold(
              body: TestBody(_focusnode, _controller),
              bottomNavigationBar: TestBottom())),
    );
  }

  Widget TestBody(_focusnode, _controller) {
    return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              focusNode: _focusnode,
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Input',
              ),
            ),
            TextButton(
              child: Text('난 텍스트버튼'),
              onPressed: () {
                print('텍스트 버튼 눌림');
              },
            ),
          ],
        ));
  }

  Widget TestBottom() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        child: Text('hello'),
        onPressed: () {},
      ),
    );
  }
}

int _idx = 0;
