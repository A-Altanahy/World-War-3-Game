# الحرب العالمية ||| (World War 3) 🎮

A strategic board game built with Flutter, inspired by Risk and Family Feud. Control territories on an interactive SVG map, build your team's army, and conquer your opponents through strategic moves and quiz-based challenges.

## ✨ Features

- **Interactive SVG Maps** — Click directly on vector-based country regions to claim territories
- **Two Map Modes** — Full 42-region map or quick 20-region map for faster games
- **Team-Based Gameplay** — Support for 2-8 teams with customizable names and colors
- **Command Center UI** — Dark neon-themed military interface with Arabic RTL support
- **Quiz System** — Built-in question bank with categories, custom questions, and image-based Q&A
- **Save/Load** — Up to 5 save slots with metadata and resume capability
- **Base Mechanics** — Strategic base/fortress system with troop bonuses and cascade captures
- **Fullscreen Mode** — F11 toggle for immersive gameplay

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- Windows desktop development tools (for Windows builds)

### Setup
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/world-war-3.git
cd world-war-3

# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows
```

### Build for Distribution
```bash
flutter build windows
```

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point & window setup
├── models/                    # Data models
│   ├── country.dart           # Country/territory model
│   ├── country_configuration.dart  # Map configuration
│   ├── country_positions.dart # Normalized positions & SVG IDs
│   ├── question.dart          # Question model
│   ├── question_category.dart # Category model
│   ├── question_state.dart    # Question revealed/answered state
│   └── team.dart              # Team model
├── pages/                     # Full-screen pages
│   ├── configuration_selection_page.dart  # Main menu
│   ├── map_page.dart          # Main game screen
│   ├── map_selection_page.dart # Map picker
│   ├── manage_questions_page.dart  # Question management
│   ├── category_details_page.dart  # Category editor
│   ├── save_slots_page.dart   # Save/load UI
│   └── team_setup_page.dart   # Team configuration
├── services/                  # Business logic
│   ├── game_state.dart        # Core game state (ChangeNotifier)
│   ├── game_storage_service.dart  # Save/load persistence
│   ├── configuration_service.dart # Map config service
│   └── question_service.dart  # Question bank management
├── theme/
│   └── app_theme.dart         # Dark neon theme constants
├── utils/
│   ├── fullscreen_helper.dart # Fullscreen toggle
│   ├── hex_color.dart         # Hex string → Color converter
│   └── svg_path_parser.dart   # SVG path data parser
└── widgets/                   # Reusable components
    ├── command_card.dart       # Neon-bordered card & button
    ├── map_preview_card.dart   # Map thumbnail for selection
    ├── question_dialog.dart    # Quiz dialog with animations
    └── vector_map.dart        # Interactive SVG map renderer
```

## 🎯 How to Play

1. **Select a Map** — Choose between the 42-region or 20-region map
2. **Set Up Teams** — Configure 2-8 teams with unique names and colors
3. **Distribution Phase** — Click territories to assign them to teams
4. **Start War** — Transition to the war phase for combat
5. **Quiz Battles** — Use the question system to challenge opponents
6. **Save & Resume** — Save your progress at any time

## 🛠 Tech Stack

- **Flutter** — Cross-platform UI framework
- **Provider** — State management
- **flutter_svg** — SVG rendering
- **shared_preferences** — Local persistence
- **window_manager** — Desktop window control
- **flutter_colorpicker** — Team color selection

## 📄 License

This project is for personal/educational use.
