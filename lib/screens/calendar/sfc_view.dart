import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SFCalendarView extends StatelessWidget {
  const SFCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
        ),
        body: SfCalendar(
          view: CalendarView.month,
          //initialDisplayDate: DateTime(2024, 6, 1),
          // headerHeight: 0,
          // viewHeaderHeight: 0,
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          ),
        ),
      ),
    );
  }
}
