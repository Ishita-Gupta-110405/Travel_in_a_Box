# Travel in a Box: AI-Powered Smart Travel Planner

An intelligent, cross-platform mobile application engineered to automate the travel planning lifecycle. This project integrates asynchronous AI processing, dynamic state management, and context-aware packing logic with localized offline fallback capabilities.

##  System Architecture & Core Engineering
* **State Management:** Implemented **Provider-based MVVM architecture** to strictly decouple the UI presentation layer from business logic and backend Firebase services, ensuring high scalability and testability.
* **Asynchronous AI Processing:** Integrated **Gemini 2.0 Flash Vision** via REST APIs to automatically classify clothing images, generating semantic wardrobe tags without requiring manual user data entry.
* **Resilient Data Layer:** Engineered a dual-layer data approach utilizing **Firebase Firestore** for cloud synchronization and **SQLite** for robust offline fallback logic, ensuring uninterrupted access to core itineraries.
* **Context-Aware Logic Engine:** Developed a dynamic packing engine that correlates real-time meteorological data (via **OpenWeatherMap API**) with AI-generated wardrobe tags to output deterministic, weather-optimized packing lists.

##  Tech Stack
* **Frontend:** Flutter, Dart
* **Backend & Cloud:** Firebase Auth, Cloud Firestore, Node.js
* **Local Database:** SQLite
* **APIs & AI:** Gemini 2.0 Flash Vision, OpenWeatherMap API

##  Core Features
* **AI Wardrobe Digitization:** Automated clothing categorization and semantic tagging via vision models.
* **Smart Itinerary Generation:** Algorithmic generation of localized travel plans.
* **Dynamic Packing Engine:** Weather-dependent packing lists combining API data and user wardrobe state.
* **Localized Gear Marketplace:** Integrated module for region-specific travel gear.

##  Getting Started
### Prerequisites
- Flutter SDK (v3.0.0+)
- Dart SDK
- Firebase CLI (for backend configuration)

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/Ishita-Gupta-110405/Travel_in_a_Box.git](https://github.com/Ishita-Gupta-110405/Travel_in_a_Box.git)
