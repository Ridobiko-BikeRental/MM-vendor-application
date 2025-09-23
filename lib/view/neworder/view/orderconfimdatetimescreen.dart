import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class ConfirmDateTime extends StatefulWidget {
  final String orderId;
  final Function(String date, String time) onSubmit;

  const ConfirmDateTime({
    super.key,
    required this.orderId,
    required this.onSubmit,
  });

  @override
  State<ConfirmDateTime> createState() => _ConfirmDateTimeState();
}

class _ConfirmDateTimeState extends State<ConfirmDateTime> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Select Delivery Date',
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() => _dateController.text = formattedDate);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? Container(),
      ),
      helpText: 'Select Delivery Time',
    );
    if (picked != null) {
      String formattedTime =
          picked.hour.toString().padLeft(2, '0') +
          ':' +
          picked.minute.toString().padLeft(2, '0');
      setState(() => _timeController.text = formattedTime);
    }
  }

  void _handleSubmit() {
    if (_dateController.text.trim().isEmpty ||
        _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both date and time")),
      );
      return;
    }
    widget.onSubmit(_dateController.text.trim(), _timeController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Confirm Order",
          style: TextStyle(color: AppColors.background),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.background),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                label: Text("Date"),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColors.primary),
                  onPressed: _pickDate,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: InputDecoration(
                label: Text("Time"),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time, color: AppColors.primary),
                  onPressed: _pickTime,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
