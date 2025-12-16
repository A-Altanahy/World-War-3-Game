# Updated Question Categories Structure

## Categories Overview

The question system now has 3 main categories:

### 1. عام (General) - Blue (#2196F3)
- **Type**: Image questions where the image shows something and the answer is the name
- **Source**: Images from `assets/questions/images/global/` folder
- **Format**: Each image filename is the answer to the question
- **Total Questions**: 13

**Questions List:**
1. ليمون
2. ايسلاند  
3. 5g
4. الربع الخالي
5. الرأس مالية
6. سمبوسه
7. دجاج مسحب
8. شطرنج
9. اوبر
10. عصفور
11. كارفور
12. شاورما
13. محار

### 2. خمن الشخص (Guess the Person) - Orange (#FF9800)
- **Type**: Image questions showing a person, answer is their name
- **Source**: Images from `assets/questions/images/people/` folder
- **Format**: Each image filename is the answer (person's name)
- **Total Questions**: 4

**Questions List:**
1. حسن ياسر
2. عادل
3. عمر محمد
4. يوسف سعيد

### 3. من عينه (From His Eye) - Purple (#9C27B0)
- **Type**: Question and answer both are images
- **Source**: Images from `assets/questions/images/` (root level)
- **Format**: Questions are `Xq.jpg` and answers are `Xa.jpg` (where X is 1-5)
- **Total Questions**: 5

**Questions List:**
1. 1q.jpg -> 1a.jpg
2. 2q.jpg -> 2a.jpg
3. 3q.jpg -> 3a.jpg
4. 4q.jpg -> 4a.jpg
5. 5q.jpg -> 5a.jpg

## File Structure

```
assets/questions/
├── categories.json       # 3 categories defined
├── questions.json        # 22 total questions
├── images/
    ├── 1q.jpg - 5q.jpg   # Questions for "من عينه"
    ├── 1a.jpg - 5a.jpg   # Answers for "من عينه"
    ├── global/           # Images for "عام" category
    │   ├── lemon.jpg
    │   └── ...
    └── people/           # Images for "خمن الشخص" category
        ├── hasan_yasser.jpg
        ├── adel.jpg
        ├── omar_mohammad.jpg
        └── yousef_saeed.jpg
```

## How It Works

1. **عام**: Shows an image, player guesses what it is
2. **خمن الشخص**: Shows a person's image, player guesses who they are  
3. **من عينه**: Shows a "question" image from someone's perspective, then shows the "answer" image

## Total Questions: 22
- عام: 13 أسئلة
- خمن الشخص: 4 أسئلة  
- من عينه: 5 أسئلة

The system randomly selects unrevealed questions from each category, ensuring variety in gameplay.
