# Daily Tally - Flutter Expense Tracker

A mobile application for tracking monthly expenses and income, built with Flutter.

## Features

- Add, edit, and delete financial transactions
- Categorize entries as income or expense
- Predefined categories for both income and expenses
- Monthly summary showing total income, expenses, and balance
- Swipe to delete transactions
- Local SQLite database storage

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or VS Code with Flutter extensions
- Android/iOS simulator or physical device

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Connect a device or start an emulator
5. Run `flutter run`

## Usage

1. **Adding a Transaction**
   - Tap the '+' button
   - Select date using the calendar
   - Enter description and amount
   - Choose transaction type (Income/Expense)
   - Select a category
   - Tap 'Add Transaction'

2. **Editing a Transaction**
   - Tap on any transaction in the list
   - Modify details in the popup
   - Tap 'Update Transaction'

3. **Deleting a Transaction**
   - Swipe a transaction left or right
   - Transaction will be immediately deleted

4. **Changing Month**
   - Tap the calendar icon in the app bar
   - Select desired month to view transactions

## Categories

### Income Categories
- Salary
- Freelance
- Investment
- Rent
- Other Income

### Expense Categories
- Food
- Transportation
- Utilities
- Rent
- Shopping
- Entertainment
- Healthcare
- Education
- Other Expense

## Technologies Used

- Flutter
- Dart
- Provider (State Management)
- SQLite
- intl (Internationalization)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source. Modify and use as you wish.
