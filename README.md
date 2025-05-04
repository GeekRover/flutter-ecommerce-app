# Flutter E-Commerce App

A comprehensive mobile e-commerce application built with Flutter and Firebase, offering both user and admin functionalities.

![App Logo](assets/images/logo.png)

## Features

### User Features
- **User Authentication**: Secure login and registration with email/password
- **Product Browsing**: Browse products with category filtering
- **Search Functionality**: Find products easily with search feature
- **Shopping Cart**: Add, update, and remove items from cart
- **Checkout Process**: Complete purchase with shipping and payment options
- **Order Tracking**: View order history and track current orders
- **User Profile**: Update personal information and view past orders

### Admin Features
- **Dashboard**: View key metrics (products, orders, users)
- **Product Management**: Add, edit, and delete products
- **Order Management**: Process orders and update order status
- **Category Management**: Create and manage product categories

## Technology Stack

- **Frontend**: Flutter
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **State Management**: Provider Pattern

## Installation

### Prerequisites
- Flutter SDK (latest version)
- Android Studio / VS Code
- Firebase account
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/flutter-ecommerce-app.git
   cd flutter-ecommerce-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Set up Firestore Database
   - Set up Firebase Storage
   - Download and add `google-services.json` to `android/app/`
   - Update Firebase security rules

4. **Firebase Security Rules**

   For Firestore:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read;
         allow write: if request.auth != null;
       }
     }
   }
   ```

   For Storage:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read;
         allow write: if request.auth != null;
       }
     }
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/       # Theme and constant values
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
│   ├── admin/       # Admin screens
│   ├── auth/        # Authentication screens
│   ├── cart/        # Cart and checkout screens
│   ├── product/     # Product screens
│   └── profile/     # User profile screens
├── services/        # Firebase services
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## Usage

### User Access
- Register a new account or login with existing credentials
- Browse products by category or search for specific items
- Add products to cart and proceed to checkout
- View order history in the profile section

### Admin Access
- Login with admin credentials (role must be set to 'admin' in Firestore)
- Access admin dashboard from the home screen
- Manage products, orders, and categories
- View store statistics and metrics

## Testing

You can use the following test account:
- Email: test@example.com
- Password: password123

For admin access:
- Email: admin@example.com
- Password: admin123

## Future Enhancements

- Payment gateway integration
- Push notifications for order updates
- User reviews and ratings
- Wishlist functionality
- Social media login options
- Advanced filtering and sorting options
- Multi-language support

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Firebase Plugins](https://github.com/firebase/flutterfire)