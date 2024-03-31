# Pulse Social Essential

Pulse Social Essential is a comprehensive social media app built with Flutter, designed to connect people through posts, likes, comments, and real-time interactions. This app not only focuses on user-generated content but also integrates a unique feature for peer-to-peer payments within the social network, making use of UPI IDs for transactions.

## Features

### User Authentication
- **Sign-up**: New users can join Pulse Social Essential by creating an account.
- **Login**: Returning users can access their accounts securely.
- **Password Recovery**: Users can recover their accounts through a password reset feature.

### Social Interactions
- **Create Posts**: Users can share their thoughts, images, and more with their followers.
- **View Posts**: Scroll through a feed of posts from users you follow.
- **Like and Comment**: Engage with content by liking posts and commenting on them.
- **Real-time Updates**: Get instant notifications for new posts and interactions.

### Payments
- Users can send and receive money from their followers using UPI IDs, formatted as `username@cashswift`.

### User Experience
- **Intuitive UI**: A clean and engaging interface for an enjoyable social experience.
- **Smooth Transitions**: Effortlessly navigate between screens and functionalities.
- **Responsive Design**: A layout that adapts to various screen sizes and orientations for consistent user experience across devices.

### Data Management
- Efficient handling of user-generated content, ensuring quick storage and retrieval of posts and comments.

### Error Handling
- Comprehensive error management to handle scenarios like failed login attempts or server errors, ensuring a smooth user experience.

## Technology Stack
- **Frontend**: Flutter
- **Backend**: Firebase Firestore, Firebase Authentication
- **Other Technologies**: Firebase Storage for media, Firebase Cloud Functions for server-side logic

## Demo
A full project demonstration can be viewed [here](https://drive.google.com/drive/folders/1hhEKZyGCnw1eM1Csqx4_NYmUN0O8GMcF?usp=sharing). 

## Known Issues
- **Web Image Loading**: Images may not load correctly on web platforms even after setting up `cors.json`. This is under investigation.
- **Transaction History**: There might be delays or issues with updating the transaction history in real-time. Efforts are being made to resolve this.
- Unfinished Chat Feature.

## Contributing
We welcome contributions to Pulse Social Essential! If you have suggestions or encounter issues, please open an issue or submit a pull request.

## License

## Dependencies
To ensure the app runs as expected, the following dependencies are used:
```yaml
dependencies:
  animated_text_kit: ^4.2.2
  cached_network_image: ^3.3.1
  cloud_firestore: ^4.15.9
  cupertino_icons: ^1.0.6
  firebase_auth: ^4.17.9
  firebase_core: ^2.27.1
  firebase_storage: ^11.6.10
  flutter:
    sdk: flutter
  flutter_spinkit: ^5.2.1
  flutter_staggered_animations: ^1.1.1
  flutter_staggered_grid_view: ^0.7.0
  flutter_svg: ^2.0.10+1
  image_cropper: ^5.0.1
  image_picker: ^1.0.7
  intl: ^0.19.0
  provider: ^6.1.2
  qr_flutter: ^4.1.0
  transparent_image: ^2.0.1
  uuid: ^4.3.3

dev_dependencies:
  flutter_lints: ^3.0.0
  flutter_test:
    sdk: flutter
