# Multi-Currency Expense Tracker

A Flutter application for tracking expenses in multiple currencies, built using the **MVC (Model-View-Controller)** architecture. The app allows users to add, edit, and delete expenses, view total expenses in a selected base currency, and sync data with a remote server when online. It supports offline functionality with a local SQLite database and includes real-time currency conversion.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Expense Management**: Add, edit, and delete expenses with details like title, amount, currency, category, and date.
- **Multi-Currency Support**: Convert expenses to a selected base currency (e.g., USD, EUR, GBP, JPY, INR) using real-time exchange rates.
- **Offline Support**: Store expenses locally using SQLite and sync with a server when online.
- **Category Selection**: Categorize expenses (e.g., Food, Transport, Shopping) with visual icons and colors.
- **Summary Dashboard**: View total expenses in the base currency and the number of expenses.
- **Animations**: Smooth UI transitions for adding/editing expenses.
- **Sync Queue**: Queue actions (create, update, delete) for offline syncing.

## Architecture

The application follows the **MVC (Model-View-Controller)** pattern to ensure a clean separation of concerns, maintainability, and scalability.

- **Model**:

  - `Expense`: Represents an expense entity with properties like `id`, `title`, `amount`, `currency`, `category`, `date`, `synced`, and `action`.
  - `DatabaseService`: Manages SQLite database operations for storing and retrieving expenses and sync queue data.
  - `CurrencyService`: Handles fetching and caching exchange rates for currency conversion.
  - `SyncService`: Manages syncing of local data with a remote server.

- **View**:

  - `ExpenseListScreen`: Displays the list of expenses, a summary card with total expenses, and options to change the base currency or sync data.
  - `AddEditExpenseScreen`: Provides a form to add or edit expenses with fields for title, amount, currency, category, and date.
  - `CategorySelector`: A reusable widget for selecting expense categories with animated visuals.

- **Controller**:
  - `ExpenseController`: Manages the business logic, including loading expenses, calculating totals in the base currency, changing the base currency, and handling CRUD operations.

The **GetX** package is used for state management and navigation, providing reactive state updates and dependency injection.

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/your-username/expense-tracker.git
   cd expense-tracker
   ```

2. **Install Dependencies**:
   Ensure you have Flutter installed. Run:

   ```bash
   flutter pub get
   ```

3. **Set Up Environment Variables**:

   - Create a `.env` file in the root directory.
   - Add the API key and base URL for the currency conversion service:
     ```env
     API_KEY=your_currency_api_key
     BASE_URL=https://v6.exchangerate-api.com/v6
     ```

4. **Run the App**:
   ```bash
   flutter run
   ```

## Usage

- **Add an Expense**: Tap the floating action button (`+`) to open the `AddEditExpenseScreen`. Enter the expense details (title, amount, currency, category, date) and save.
- **Edit an Expense**: Tap an expense in the `ExpenseListScreen` to edit its details.
- **Delete an Expense**: Long-press an expense to show a confirmation dialog for deletion.
- **Change Base Currency**: Use the dropdown in the app bar to select a base currency. The total expenses will be converted accordingly.
- **Sync Data**: Press the sync button in the app bar to sync offline changes with the server when online.
- **View Summary**: The summary card displays the total expenses in the selected base currency and the number of expenses.

## File Structure

```plaintext
expense_tracker/
├── lib/
│   ├── controller/
│   │   └── expense_controller.dart
│   ├── models/
│   │   └── expense.dart
│   ├── services/
│   │   ├── currency_service.dart
│   │   └── database_service.dart
│   ├── utils/
│   │   └── app_env.dart
│   ├── view/
│   │   ├── screens/
│   │   │   ├── add_edit_expense_screen.dart
│   │   │   ├── category_selector_screen.dart
│   │   │   └── expense_screen.dart
│   └── main.dart
├── .env
├── pubspec.yaml
└── README.md
```

- **controller/**: Contains the `ExpenseController` for managing business logic.
- **models/**: Defines the `Expense` data model.
- **services/**: Includes services for database operations (`DatabaseService`), currency conversion (`CurrencyService`), and syncing (`SyncService`).
- **utils/**: Contains utility files like `app_env.dart` for environment variable management.
- **view/screens/**: Contains UI screens and widgets for the app.
- **main.dart**: Entry point of the application.

## Dependencies

The app uses the following dependencies (defined in `pubspec.yaml`):

- `flutter`: Core Flutter framework.
- `get`: For state management and navigation.
- `sqflite`: For local SQLite database storage.
- `path`: For handling file paths.
- `http`: For making API requests to fetch exchange rates.
- `flutter_dotenv`: For loading environment variables.
- `intl`: For date formatting.
- `logger`: For logging during development.

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
  sqflite: ^2.0.2
  path: ^1.8.0
  http: ^0.13.4
  flutter_dotenv: ^5.0.2
  intl: ^0.17.0
  logger: ^1.1.0
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
