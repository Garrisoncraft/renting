import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/authentication.dart';
import 'screens/home_screen.dart';
import 'screens/landlord_dashboard_screen.dart';
import 'screens/manage_properties_screen.dart';
import 'screens/tenant_dashboard.dart';
import 'screens/property_listing.dart';
import 'screens/property_search.dart';
import 'screens/property_details.dart';
import 'services/firebase_property_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "your-api-key",
      authDomain: "your-auth-domain",
      databaseURL: "your-database-url",
      projectId: "your-project-id",
      storageBucket: "your-storage-bucket",
      messagingSenderId: "your messaging-sender-id",
      appId: "your-app-id",
      measurementId: "your-measurementId"
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebasePropertyService>(
          create: (_) => FirebasePropertyService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthenticationScreen(),
        '/home': (context) => const HomeScreen(),
        '/listing': (context) => const PropertyListingScreen(),
        '/search': (context) => const PropertySearchScreen(),
        '/details': (context) {
          final property = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PropertyDetailsScreen(property: property);
        },
        '/landlord_dashboard': (context) => const LandlordDashboardScreen(),
        '/manage': (context) => const ManagePropertiesScreen(),
        '/tenant_dashboard': (context) => const TenantDashboard(),
      },
    );
  }
}
