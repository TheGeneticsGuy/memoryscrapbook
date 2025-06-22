import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // This is for local storage
import 'package:memoryscrapbook/models/memory_entry.dart';
import 'package:memoryscrapbook/screens/create_memory_screen.dart';

void main() async {     // Note, I had to make this async because of await for memory retrieval
  WidgetsFlutterBinding.ensureInitialized();  // Built-in feature to ensure that the plgin servers are initialized
  await Hive.initFlutter();                   // Not going to run the app until the Hive (data) is loaded
  Hive.registerAdapter(MemoryEntryAdapter());

  // Ok, now let's run the app - code below
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This @override is a Java feature (or really OOP feature as I remember this in C# .Net 325 class as well) to override extended function
  // from the StatelessWidget class!
  // Returns a MaterialApp configured with a title, theme, and home screen.
  // To build and return the main root UI structure of the app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Scrapbook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MemoryLogScreen(title: 'Memory Scrapbook'), // Just the home page placeholder
    );
  }
}

// Creates an instance of the MemoryLogScreen widget to a specific title
class MemoryLogScreen extends StatefulWidget {

  // Constructor
  const MemoryLogScreen({super.key, required this.title});
    final String title;

  // This links the StatefulWidget with the connected state
  @override
  State<MemoryLogScreen> createState() => _MemoryLogScreenState();
}

// Ok, let's get to the home page
class _MemoryLogScreenState extends State<MemoryLogScreen> {

  // For the visual elements of the home page and scaffolding
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,    // Neat trick to get complimentary color
        title: Text(widget.title),
      ),

      // Text of the body on the home page
      body: const Center(
        child: Text(
          'Welcome! Your memories will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),

      // Add a new memory button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMemoryScreen()),
          );
        },

        // This is so I can click the add a photo b utton which opens the add a new memory
        tooltip: 'Create a Memory',
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }
}