import 'package:flutter/material.dart';

class CustomSidebarModal {
  final List<dynamic>? calendarList;
  final Function(int)? onCalendarSelected;

  CustomSidebarModal(this.calendarList, {this.onCalendarSelected});

  void sidebarModal(BuildContext context) {
    showModalSideSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              children: [
                ...calendarList!.map((calendar) {
                  return ListTile(
                    title: Text('캘린더 ${calendar['calendarId']}번'),
                    onTap: () {
                      // set calendarId to the selected calendar
                      if (onCalendarSelected != null) {
                        onCalendarSelected!(calendar['calendarId']);
                      }
                    },
                  );
                }).toList(),
                // Add more items as needed
              ],
            ),
          ),
        );
      },
    );
  }
}

void showModalSideSheet({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    //barrierColor: Colors.black, // turn off the background color
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          child: builder(context),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
