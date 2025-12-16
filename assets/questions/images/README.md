# Sample Images for Questions

This folder contains sample images referenced in the questions.json file.

For a complete implementation, you should add the following image files:

## Question Images:
- `pyramid_question.jpg` - Image showing pyramids for the history question
- `flag_question.png` - Image showing a country flag for geography question  
- `solar_system.jpg` - Image showing solar system for science question
- `tennis_question.jpg` - Image showing tennis court/tournament for sports question

## Answer Images:
- `solar_system_answer.jpg` - Labeled solar system image as answer

## Category Icons (optional):
- `history_icon.png` - Icon for history category
- `geography_icon.png` - Icon for geography category  
- `science_icon.png` - Icon for science category
- `literature_icon.png` - Icon for literature category
- `sports_icon.png` - Icon for sports category

## Image Guidelines:
- Use common formats: JPG, PNG, GIF
- Recommended size: 800x600 pixels or smaller for good performance
- Keep file sizes reasonable (under 2MB per image)
- Use descriptive filenames
- Ensure images are appropriate for your target audience

## Alternative Text-Only Questions:
If you prefer not to use images, you can modify the questions.json file to remove the `imagePath` and `answerImagePath` fields and use only `text` and `answerText` fields.
