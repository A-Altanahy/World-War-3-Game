# World War 3 Game (الحرب العالمية الثالثة)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Web%20%7C%20Desktop-informational)](#running-locally)
[![Game](https://img.shields.io/badge/Type-Strategy%20%2B%20Quiz-success)](#gameplay)

An Arabic RTL strategy game built with Flutter. It combines Risk-style territory control with quiz-based challenges, team customization, save/load support, and interactive SVG maps.

## Highlights

- Interactive vector maps with clickable country regions.
- Two map configurations: a full 42-region map and a faster 20-region map.
- Team setup for multiple players with custom names and colors.
- Quiz challenge system with category management, image questions, and bundled question packs.
- Base and troop mechanics for territory defense and strategic captures.
- Local save slots with match metadata for resuming games.
- Desktop-first fullscreen presentation with Arabic UI.

## Tech Stack

- Flutter and Dart.
- `provider` for state management.
- `flutter_svg` for SVG map rendering.
- `shared_preferences` and file utilities for local state and content persistence.
- `file_picker`, `image_picker`, `video_player`, and `just_audio` for media-driven questions.
- `window_manager` for desktop window behavior.

## Architecture

```text
lib/
├── main.dart                         # Bootstrap, localization, desktop window setup
├── models/                           # Country, team, question, and category models
├── pages/                            # Setup, map, saves, question management, editors
├── services/                         # Game state, storage, map config, question service
├── theme/                            # Command-center visual theme
├── utils/                            # Fullscreen, color, and SVG path helpers
└── widgets/                          # Interactive map, question dialog, media player, UI cards

assets/
├── original_full_map(42).svg         # Full world map
├── original_map(20).svg              # Quick-play map
└── questions/                        # Bundled categories, questions, and media assets
```

## Gameplay

1. Select a map configuration.
2. Configure teams and colors.
3. Assign territories during the distribution phase.
4. Start the war phase and resolve attacks through quiz challenges.
5. Use base mechanics and troop points to defend territory.
6. Save and resume games from local save slots.

## Running Locally

### Prerequisites

- Flutter SDK 3.x or later.
- Desktop build tools for the target platform.

### Setup

```bash
git clone https://github.com/A-Altanahy/World-War-3-Game.git
cd World-War-3-Game
flutter pub get
flutter run -d windows
```

For web:

```bash
flutter run -d chrome
```

## Testing

```bash
flutter test
```

## Portfolio Focus

This project shows Flutter game UI development, custom SVG interaction, state management, local persistence, Arabic RTL design, and media-backed quiz workflows in a single application.
