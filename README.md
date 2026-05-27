# macOS Memory Game

A visually appealing, high-performance macOS memory game built with Flutter.

![Kids Memory Trainer](images/kids-memory-trainer.png)

## Features

- **Massive 12x12 Grid:** Challenge your memory with 144 cards (72 distinct, procedurally generated color pairs).
- **Single-Player Time Trial:** Clear the board as fast as possible. Your fastest times are recorded.
- **Local Multiplayer (Hotseat):** Play against a friend on the same Mac. Take turns finding matches to score points.
- **Local Leaderboards:** Persistent local storage for both Single-Player fastest times and Multiplayer high scores.
- **3D Animations:** Smooth card flipping animations utilizing Flutter's `Transform` matrix.
- **Native macOS Feel:** Styled with dark mode defaults and standard typography to feel at home on macOS.

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.3.0 or higher)
- macOS (for native desktop execution)

### Installation & Running

1. **Clone or navigate to the project directory:**
   ```bash
   cd path/to/flutter-test
   ```

2. **Generate the native macOS runner:**
   Because this project is configured for macOS, ensure the platform scaffolding is generated:
   ```bash
   flutter create . --platforms=macos
   ```

3. **Install Dependencies:**
   Fetch the required packages (`shared_preferences`, `uuid`):
   ```bash
   flutter pub get
   ```

4. **Run the Application:**
   Launch the game natively on your Mac:
   ```bash
   flutter run -d macos
   ```

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Storage:** `shared_preferences` for local leaderboard persistence
- **State Management:** Flutter `ChangeNotifier`

## License
This project is for demonstration and learning purposes.
