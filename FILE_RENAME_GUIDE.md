# File Renaming Guide for Flutter Assets

## Issue
Flutter on Windows has difficulty loading assets with Arabic filenames. The error "صورة غير متوفرة" indicates that images cannot be loaded.

## Solution: Rename Files to English

### Global Folder Renames:
- ليمون.jpg → lemon.jpg
- ايسلاند.jpg → iceland.jpg  
- 5g.jpg → 5g.jpg (already English)
- الربع الخالي.jpg → empty_quarter.jpg
- الرأس مالية.jpg → capitalism.jpg
- سمبوسه.jpg → samosa.jpg
- دجاج مسحب.jpg → pulled_chicken.jpg
- شطرنج.jpg → chess.jpg
- اوبر.jpg → uber.jpg
- عصفور.jpg → bird.jpg
- كارفور.jpg → carrefour.jpg
- شاورما.jpg → shawarma.jpg
- محار.jpg → oyster.jpg

### People Folder Renames:
- جاورشي.jpg → jawarshi.jpg
- زيد مهند.jpg → zaid_muhannad.jpg
- فراس.jpg → firas.jpg
- زين.jpg → zain.jpg
- عمر اسعد.jpg → omar_asaad.jpg
- فهد.jpg → fahad.jpg
- طارق.jpg → tareq.jpg

## Commands to Rename (Run in PowerShell):

```powershell
# Navigate to global folder
cd "c:\Users\ymyex\Projects\custom_risk - Copy\assets\questions\images\global"

# Rename global files
ren "ليمون.jpg" "lemon.jpg"
ren "ايسلاند.jpg" "iceland.jpg"
ren "الربع الخالي.jpg" "empty_quarter.jpg"
ren "الرأس مالية.jpg" "capitalism.jpg"
ren "سمبوسه.jpg" "samosa.jpg"
ren "دجاج مسحب.jpg" "pulled_chicken.jpg"
ren "شطرنج.jpg" "chess.jpg"
ren "اوبر.jpg" "uber.jpg"
ren "عصفور.jpg" "bird.jpg"
ren "كارفور.jpg" "carrefour.jpg"
ren "شاورما.jpg" "shawarma.jpg"
ren "محار.jpg" "oyster.jpg"

# Navigate to people folder
cd "../people"

# Rename people files
ren "جاورشي.jpg" "jawarshi.jpg"
ren "زيد مهند.jpg" "zaid_muhannad.jpg"
ren "فراس.jpg" "firas.jpg"
ren "زين.jpg" "zain.jpg"
ren "عمر اسعد.jpg" "omar_asaad.jpg"
ren "فهد.jpg" "fahad.jpg"
ren "طارق.jpg" "tareq.jpg"
```

After renaming, the questions.json file will need to be updated with the new filenames.
