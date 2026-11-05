# Design reference

29 screens at 390×844, exported from the approved design canvas
(`canvas.json` is its index). These are a **visual reference only**: build
idiomatic Flutter widgets from the theme in `lib/core/ui/theme/`, never port
the CSS. Sample data in the screens (names, amounts, ID numbers) is
placeholder and must not ship.

| File | Feature | Milestone |
|---|---|---|
| `screens/Setup.dc.html` | auth: first-time setup | 2 |
| `screens/Unlock.dc.html` | auth: unlock | 2 |
| `screens/Main.dc.html` | dashboard (light) | 4 |
| `screens/MainDark.dc.html` | dashboard (dark), defines the dark palette | 4 |
| `screens/Notes.dc.html` | notes | 4 |
| `screens/Tasks.dc.html` | tasks & checklists | 4 |
| `screens/Reminders.dc.html` | reminders | 4 |
| `screens/FormReminder.dc.html` | reminders: add/edit | 4 |
| `screens/Personal.dc.html` | personal details | 5 |
| `screens/Passwords.dc.html` | password notes | 5 |
| `screens/FormPassword.dc.html` | password notes: add/edit | 5 |
| `screens/Documents.dc.html` | document manager | 6 |
| `screens/FormDocument.dc.html` | document manager: add/edit | 6 |
| `screens/ShopHome.dc.html` | shopping: home & history | 7 |
| `screens/ShopEdit.dc.html` | shopping: edit list (manual / reuse) | 7 |
| `screens/ShopImport.dc.html` | shopping: import from message | 7 |
| `screens/ShopActive.dc.html` | shopping: session in progress | 7 |
| `screens/ShopComplete.dc.html` | shopping: finish | 7 |
| `screens/ShareCard.dc.html` | shopping: WhatsApp instruction image (render once to a 3× PNG asset, not a screen) | 7 |
| `screens/Budget.dc.html` | budget | 8 |
| `screens/FormExpense.dc.html` | budget: add expense | 8 |
| `screens/Lending.dc.html` | lending & borrowing | 8 |
| `screens/FormLending.dc.html` | lending: add/edit | 8 |
| `screens/Medicine.dc.html` | medicine schedule | 8 |
| `screens/FormMedicine.dc.html` | medicine: add/edit | 8 |
| `screens/Breathe.dc.html` | eye rest & breathing | 8 |
| `screens/Drive.dc.html` | Google Drive storage | 9 |
| `screens/Backup.dc.html` | backup & restore | 10 |
| `screens/Settings.dc.html` | settings | 11 |

Not in the design (derive from the same tokens and patterns): note editor,
task add/edit, personal-details add/edit, restore preview & confirm, Drive
upload/progress/error states, empty states, and dark variants of every
screen except the dashboard.
