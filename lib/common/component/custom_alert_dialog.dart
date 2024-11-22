import 'package:flutter/material.dart';
import 'package:mobile_client/common/component/custom_divider.dart';
import 'package:mobile_client/common/const/color.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final String acceptButtonText;
  final String cancelButtonText;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onAccept,
    required this.onCancel,
    this.acceptButtonText = '확인',
    this.cancelButtonText = '취소',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // Background color
      backgroundColor: ColorPalette.GRAY_COLOR[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 4),
            // Content
            Text(
              content,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Divider(
              thickness: 1.0,
              color: ColorPalette.GRAY_COLOR[200]!,
              height: 0,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          cancelButtonText,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Vertical Divider
                Container(
                  width: 1.0,
                  height: 48.0,
                  color: ColorPalette.GRAY_COLOR[200]!,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          acceptButtonText,
                          style: TextStyle(
                            color: ColorPalette.ERROR_COLOR[400]!,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
