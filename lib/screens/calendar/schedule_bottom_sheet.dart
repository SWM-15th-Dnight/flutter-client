import 'package:flutter/material.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:mobile_client/widget/auth_text_form_field.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({super.key});

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String summary = '';
  String startAt = '';
  String endAt = '';
  String description = '';
  int priority = 5;

  Future<void> _submitForm() async {
    print('_submitForm() clicked');

    Map<String, dynamic> data = {
      'summary': summary,
      'startAt': startAt,
      'endAt': endAt,
      'description': description,
      'priority': priority,
    };
    print(data);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //await MainRequest().postRequest('/api/v1/event/form', data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO.
                // - set default time range
                // - if attempt to empty 'summary' event, show modal alert.
                // - (if mouse leave without any content, red alert text should be shown)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Summary',
                    hintText: '제목 없음',
                  ),
                  onSaved: (value) => summary = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a summary';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Start At'),
                  onSaved: (value) => startAt = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'End At'),
                  onSaved: (value) => endAt = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an end time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) => description = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Priority'),
                  value: priority,
                  items: List.generate(9, (index) => index + 1)
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.toString()),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    priority = value!;
                  }),
                  onSaved: (value) => priority = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    Navigator.of(context).pop();
                  },
                  child: Text('등록'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
