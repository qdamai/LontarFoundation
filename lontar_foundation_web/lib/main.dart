import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Import all pages
import 'pages/home_page.dart';
import 'pages/category_page.dart';
import 'pages/item_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/product_list_page.dart'; // Import the new page
import 'pages/contact_us_page.dart'; // Import Contact Us page

// Import providers and services
import 'services/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD3oZBv9snxqulidSgKTsH06TPT8D8EVPM",
      authDomain: "lontar-abcs.firebaseapp.com",
      projectId: "lontar-abcs",
      storageBucket: "lontar-abcs.appspot.com",
      messagingSenderId: "433827741036",
      appId: "1:433827741036:web:0821e2f148196489c68749",
      measurementId: "G-HJKXGF11CS",
    ),
  );
  runApp(const LontarApp());
}

class LontarApp extends StatelessWidget {
  const LontarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // New Color Palette
    const Color background = Color(0xFFFDF6ED);
    const Color primaryAccent = Color(0xFF6D4C41);
    const Color secondaryAccent = Color(0xFFB5835A);
    const Color highlight = Color(0xFFA44200);
    const Color textTitle = Color(0xFF3B2F2F);
    
    final TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: textTitle, letterSpacing: 0.5),
      headlineMedium: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: textTitle),
      titleLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textTitle),
      bodyLarge: GoogleFonts.inter(fontSize: 11, color: textTitle, height: 1.7),
      bodyMedium: GoogleFonts.inter(fontSize: 10, color: textTitle, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: background)
    );

    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'Lontar Foundation',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryAccent,
            primary: primaryAccent,
            secondary: secondaryAccent,
            surface: background,
            onSurface: textTitle,
            error: highlight,
          ),
          scaffoldBackgroundColor: background,
          textTheme: textTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: background.withAlpha(230),
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textTitle),
            iconTheme: const IconThemeData(color: primaryAccent),
          ),
           textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryAccent,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600)
            )
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: highlight,
              foregroundColor: background,
              textStyle: textTheme.labelLarge,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            )
          )
        ),
        // We use onGenerateRoute for more complex routing with arguments
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const HomePage());
            case '/category':
              return MaterialPageRoute(builder: (_) => const CategoryPage());
            case '/contact':
              return MaterialPageRoute(builder: (_) => const ContactUsPage());
            case '/cart':
               return MaterialPageRoute(builder: (_) => const CartPage());
            case '/checkout':
               return MaterialPageRoute(builder: (_) => const CheckoutPage());
            case '/item':
              return MaterialPageRoute(builder: (_) => const ItemDetailPage());
            case '/products':
              if (settings.arguments is String) {
                return MaterialPageRoute(builder: (_) => ProductListPage(category: settings.arguments as String));
              }
              return MaterialPageRoute(builder: (_) => const CategoryPage()); // Fallback
            default:
              return MaterialPageRoute(builder: (_) => const HomePage());
          }
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 