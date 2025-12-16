# Question Feature Documentation

## Overview
The question feature allows players to access categorized questions during the game. Players can select a category and receive random unrevealed questions from that category. Each question can have text or image content, and answers can also be text or images.

## Feature Components

### 1. Data Models
- **Question**: Represents a single question with its answer
- **QuestionCategory**: Represents a category of questions (e.g., History, Geography)
- **QuestionState**: Tracks whether a question has been revealed/answered in the current game

### 2. Service Layer
- **QuestionService**: Manages loading questions from JSON files and tracking question states

### 3. UI Components
- **QuestionDialog**: Main dialog for displaying categories and questions
- **Question Button**: Floating action button on the map page (الأسئلة)

## How to Use

### In-Game Usage
1. Click the "الأسئلة" (Questions) button on the map page
2. Select a question category from the grid
3. View the question (text or image)
4. Click "إظهار الإجابة" (Show Answer) to reveal the answer
5. Click "سؤال آخر" (Another Question) for the next question in the same category
6. Click "إنهاء" (Finish) to close the dialog

### Adding New Content

#### Categories (assets/questions/categories.json)
```json
{
  "categories": [
    {
      "id": "unique_category_id",
      "name": "اسم الفئة",
      "description": "وصف الفئة",
      "iconPath": "images/icon.png",
      "color": "#HEX_COLOR"
    }
  ]
}
```

#### Questions (assets/questions/questions.json)
```json
{
  "questions": [
    {
      "id": "unique_question_id",
      "categoryId": "category_id",
      "text": "نص السؤال (اختياري)",
      "imagePath": "images/question_image.jpg (اختياري)",
      "answerText": "نص الإجابة (اختياري)",
      "answerImagePath": "images/answer_image.jpg (اختياري)",
      "difficulty": 1
    }
  ]
}
```

## File Structure
```
assets/
  questions/
    categories.json          # Question categories
    questions.json           # All questions
    images/                  # Image assets
      README.md             # Image guidelines
      history_icon.png      # Category icons
      question_images.jpg   # Question/answer images
```

## Technical Features

### State Management
- Questions are tracked per game session
- Once revealed, a question won't appear again in the same game
- Game state resets when starting a new game

### Image Support
- Both questions and answers can use images
- Images are loaded from the assets/questions/images/ folder
- Fallback displays when images are missing
- Proper error handling for missing assets

### Randomization
- Questions are randomly selected from unrevealed questions in each category
- Ensures variety and prevents predictable question order

### Localization
- UI is in Arabic (RTL support)
- Content can be in any language by updating JSON files

## Configuration

### Adding Images
1. Place image files in `assets/questions/images/`
2. Update JSON files with the correct image paths
3. Run `flutter clean` and `flutter build` to refresh assets

### Customizing Categories
- Edit `categories.json` to add/remove/modify categories
- Update category icons and colors as needed
- Ensure question categoryId matches category id

### Difficulty Levels
- Questions have difficulty levels (1-5)
- Currently for reference only
- Can be used for filtering or scoring in future updates

## Error Handling
- Missing images show placeholder text
- Invalid JSON files are handled gracefully
- Empty categories are disabled in the UI
- Service initialization errors are logged

## Future Enhancements
- Question filtering by difficulty
- Scoring system based on difficulty
- Question history/statistics
- Import/export question sets
- Audio question support
- Timer for questions
- Multiplayer question challenges
