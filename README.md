# IEP - Investment & Crowdfunding Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20|%20Firestore%20|%20Storage-orange?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)

**IEP (Investment & Entrepreneurship Platform)** is a comprehensive cross-platform application (Mobile & Web) designed to bridge the gap between investors and project owners. It facilitates secure funding, project tracking, and real-time communication.

## Live Demo
**Try the Web Version here:** [Link to your Vercel/Firebase Hosting]  
*(Note: The web version is optimized with specific CORS policies for image handling).*

---

## Key Features

### For Users (Investors & Owners):
* **Authentication:** Secure Login/Sign-up using Email & Password.
* **Project Discovery:** Browse projects with filtering options.
* **Investment Tracking:** Real-time progress bars for funding goals.
* **Secure Payments:** Integrated payment gateway for investments.
* **Chat System:** Direct messaging between investors and owners.
* **Reporting:** Ability to report suspicious content.

### For Admins:
* **Dashboard:** Overview of platform statistics.
* **Content Moderation:** Approve, Reject, or Freeze projects.
* **Report Handling:** Review and resolve user reports.
* **User Management:** Ban/Unban users violating terms.

---

## Tech Stack & Architecture

This project follows a **Clean MVC (Model-View-Controller)** architecture adapted for Flutter's reactive nature, ensuring separation of concerns and maintainability.

| Layer | Technology / Pattern | Description |
| :--- | :--- | :--- |
| **UI (View)** | Flutter Widgets | Responsive UI for Web & Mobile. |
| **Logic (Controller)** | Provider / MVC | Handles business logic & state management. |
| **Data (Model)** | Pure Dart Models | Immutable data structures (DTOs). |
| **Backend** | Firebase | Firestore (NoSQL), Auth, Storage. |
| **Repository** | Repository Pattern | Abstracting data sources from the app logic. |

### Project Structure
```bash
lib/
├── core/           # Constants, Utils, Theme
├── mvc/
│   ├── controller/ # Business Logic (Providers)
│   ├── models/     # Data Models (Immutable)
│   ├── views/      # UI Screens & Widgets
│   └── repo/       # Data Access Layer (Firebase Calls)
└── main.dart
