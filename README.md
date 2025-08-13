# Number Master Puzzle - Flutter Game

A Flutter implementation of the Number Master puzzle game, featuring number-matching mechanics similar to the popular "Number Master" by KiwiFun. Built with clean architecture principles and modern Flutter development practices.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎮 Game Features

### Core Gameplay
- **Number Matching**: Match identical numbers (5-5, 8-8) or pairs that sum to 10 (3-7, 4-6)
- **Adjacent Matching**: Tiles must be side-by-side (horizontally, vertically, or across line breaks)
- **Visual Feedback**: Matched tiles remain visible but become faded
- **No Removal**: Matched tiles stay on the board for visual reference

### Game Mechanics
- **3 Difficulty Levels**: Beginner, Intermediate, and Expert
- **2-Minute Timer**: Complete each level within the time limit
- **Grid Layout**: 7-column grid with initially 3-4 filled rows
- **Add Row Feature**: Limited ability to add new rows when stuck
- **Progressive Difficulty**: Each level introduces more complexity

### Visual & Audio
- **Smooth Animations**: Tile selection, matching, and invalid move feedback
- **Responsive Design**: Optimized for mobile devices
- **Clean UI**: Modern Material Design 3 interface
- **Visual Effects**: Shake animations for invalid moves, fade effects for matches

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                          # Shared utilities and constants
│   ├── constants/                 # Game constants, colors, dimensions
│   ├── theme/                     # App theming configuration
│   └── utils/                     # Utility functions
├── features/
│   └── game/
│       ├── data/
│       │   └── models/           # Data models (GameState, Tile, Level)
│       ├── domain/
│       │   ├── entities/         # Business entities
│       │   └── repositories/     # Repository interfaces
│       └── presentation/
│           ├── providers/        # Riverpod state management
│           ├── screens/          # UI screens
│           └── widgets/          # Reusable UI components
├── main.dart                     # App entry point
└── app.dart                      # Main app configuration
```

### State Management
- **Riverpod**: Modern, compile-time safe state management
- **Clean Separation**: UI logic separated from business logic
- **Reactive Updates**: Automatic UI updates when state changes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Android device or emulator / iOS device or simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/meershamohammedjafar/number_master_puzzle.git
   cd number_master_puzzle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🎯 Game Rules

### Matching Rules
1. **Identical Numbers**: Match two tiles with the same number (3-3, 7-7, 9-9)
2. **Sum to Ten**: Match two tiles whose numbers add up to 10 (1-9, 2-8, 3-7, 4-6, 5-5)

### Positioning Rules
- Tiles must be **adjacent** to each other
- Adjacent means: horizontally next to each other, vertically next to each other
- **Line Break Matching**: If a tile is at the end of a row and another is at the start of the next row, they can be matched

### Game Progression
- **Objective**: Match all possible tiles before time runs out
- **Time Limit**: 2 minutes per level
- **Add Rows**: Limited number of additional rows can be added per level
- **Winning**: Complete all matches or achieve the target before time expires

## 🔧 Technical Implementation

### Key Components

**GameState Model**
```dart
class GameState {
  final List<Tile> tiles;
  final int currentLevel;
  final int score;
  final GameStatus status;
  final Duration timeRemaining;
  // ... other properties
}
```

**Tile Model**
```dart
class Tile {
  final int id;
  final int value;
  final int row;
  final int column;
  final TileState state;
  final bool isVisible;
}
```

**Game Provider (Riverpod)**
```dart
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
```

### Level Configuration
```dart
static const Map<int, Map<String, dynamic>> levels = {
  1: {
    'name': 'Beginner',
    'description': 'Easy start with simple patterns',
    'initialNumbers': 28, // 4 rows * 7 columns
    'addRowLimit': 2,
  },
  // ... more levels
};
```

## 🎨 UI Components

### Main Screens
- **HomeScreen**: Level selection and game introduction
- **GameScreen**: Main gameplay interface

### Key Widgets
- **GameBoard**: Displays the tile grid and handles interactions
- **TileWidget**: Individual tile with animations and touch handling
- **GameTimer**: Real-time countdown and score display
- **GameControls**: Start, pause, reset, and navigation buttons

## 🧪 Testing

Run tests with:
```bash
flutter test
```

### Test Coverage
- Unit tests for game logic and models
- Widget tests for UI components
- Integration tests for complete game flows

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (responsive design)

## 🔄 State Management Flow

1. **User Action**: Player taps a tile
2. **Event**: `onTileTapped()` called in GameNotifier
3. **Business Logic**: Check matching rules and adjacency
4. **State Update**: Update GameState with new tile states
5. **UI Update**: Riverpod automatically rebuilds affected widgets

## 🎯 Future Enhancements

- [ ] Sound effects and background music
- [ ] Multiplayer mode
- [ ] Daily challenges
- [ ] Achievement system
- [ ] Customizable themes
- [ ] Hint system
- [ ] Leaderboards
- [ ] More difficulty levels

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards
- Follow Flutter/Dart style guidelines
- Maintain clean architecture principles
- Add tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Number Master by KiwiFun
- Flutter team for the amazing framework
- Riverpod for excellent state management
- Material Design for UI guidelines

## 📞 Support

For questions or support:
- Create an issue on GitHub
- Email: meershajafar@example.com

---

**Made with ❤️ and Flutter**