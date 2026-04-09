import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/trip_viewmodel.dart';

class TripPlannerScreen extends StatefulWidget {
  @override
  _TripPlannerScreenState createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPace = 'Balanced';

  // NEW: Variables for preferences
  List<String> _selectedPreferences = [];
  // NEW: Expanded list of preferences
  final List<String> _availablePreferences = [
    'Museums',
    'Nature',
    'History',
    'Entertainment',
    'Nightlife',
    'Relaxation',
    'Beaches',
    'Mountains',
    'Active / Sports'
  ];

  final Color softBlue = const Color(0xFFAEC6CF);
  final Color pastelPink = const Color(0xFFFFD1DC);
  final Color offWhite = const Color(0xFFFDFDFD);
  final Color softCharcoal = const Color(0xFF4A4A4A);

  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: softBlue, onPrimary: offWhite, surface: offWhite, onSurface: softCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submitTrip() async {
    if (_destinationController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.', style: TextStyle(color: offWhite)), backgroundColor: softCharcoal),
      );
      return;
    }

    final viewModel = Provider.of<TripViewModel>(context, listen: false);

    // Pass the preferences to the brain!
    bool success = await viewModel.generateTrip(
      destination: _destinationController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      pace: _selectedPace,
      preferences: _selectedPreferences,
    );

    if (success) {
      Navigator.pop(context);
    } else if (viewModel.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage), backgroundColor: Colors.redAccent),
      );
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TripViewModel>().isLoading;

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        title: Text('Plan New Trip', style: TextStyle(color: softCharcoal, fontWeight: FontWeight.bold)),
        backgroundColor: pastelPink, elevation: 0, iconTheme: IconThemeData(color: softCharcoal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Where to? (e.g. Paris)',
                filled: true, fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: softBlue, width: 2)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _pickDateRange,
              icon: Icon(Icons.calendar_today, color: softCharcoal),
              label: Text(
                _startDate == null ? 'Select Dates' : '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}',
                style: TextStyle(color: softCharcoal),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: softBlue, elevation: 0),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedPace,
              decoration: InputDecoration(
                labelText: 'Trip Pace', filled: true, fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              items: ['Slow', 'Balanced', 'Fast'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedPace = newValue!),
            ),
            const SizedBox(height: 20),

            // NEW: The Preference Chips!
            Text('What do you love doing?', style: TextStyle(color: softCharcoal, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0, runSpacing: 4.0,
              children: _availablePreferences.map((pref) {
                return FilterChip(
                  label: Text(pref),
                  selected: _selectedPreferences.contains(pref),
                  selectedColor: pastelPink,
                  checkmarkColor: softCharcoal,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: softBlue),
                  onSelected: (bool selected) {
                    setState(() {
                      selected ? _selectedPreferences.add(pref) : _selectedPreferences.remove(pref);
                    });
                  },
                );
              }).toList(),
            ),

            const Spacer(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submitTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: pastelPink, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Generate Itinerary', style: TextStyle(fontSize: 18, color: softCharcoal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}