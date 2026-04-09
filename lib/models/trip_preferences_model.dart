class TripPreferences {
  final String city;
  final int travelers;
  final String budget;
  final List<String> selectedVibes;

  TripPreferences({
    required this.city,
    required this.travelers,
    required this.budget,
    required this.selectedVibes,
  });

  /// Converts the object into a JSON map.
  /// This is highly recommended when you are ready to send the data
  /// to an API, Firebase, or an AI prompt (like Gemini).
  Map<String, dynamic> toJson() {
    return {
      'destination': city,
      'number_of_travelers': travelers,
      'budget_tier': budget,
      'vibes_and_interests': selectedVibes,
    };
  }

  /// Generates a clean prompt string that you can feed directly to an AI
  String toAIPrompt() {
    String vibes = selectedVibes.isEmpty
        ? "a general mix of popular attractions"
        : selectedVibes.join(", ");

    return "Create a detailed travel itinerary for $travelers people going to $city. "
        "The budget is $budget. "
        "The trip should focus on: $vibes. "
        "Please include daily schedules, restaurant recommendations, and travel tips.";
  }

  // A handy toString method for debugging in your terminal
  @override
  String toString() {
    return 'Trip(City: $city, Travelers: $travelers, Budget: $budget, Vibez: $selectedVibes)';
  }
}