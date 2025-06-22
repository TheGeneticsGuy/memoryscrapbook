import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // This is for local storage
import 'package:memoryscrapbook/models/memory_entry.dart';
import 'package:memoryscrapbook/screens/create_memory_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // This was so I could display an image directly from file path (uploaded image)

void main() async {     // Note, I had to make this async because of await for memory retrieval
  WidgetsFlutterBinding.ensureInitialized();  // Built-in feature to ensure that the plgin servers are initialized

  // Local storage initializaqtion
  await Hive.initFlutter();                   // Not going to run the app until the Hive (data) is loaded
  Hive.registerAdapter(MemoryEntryAdapter());
  await Hive.openBox<MemoryEntry>('memories');

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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

    // Accesses the now open Hive Box
    final memoryBox = Hive.box<MemoryEntry>('memories');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,    // Neat trick to get complimentary color
        title: Text(widget.title),
      ),

      // The main home bage body
      // Since I can't separate HTML/CSS like on a webpage, all of the styling is
      // is integrated in so it seems a bit wordy and nested, but it's basically just the equivalent of CSS
      body: ValueListenableBuilder(
        valueListenable: memoryBox.listenable(),
        builder: (context, Box<MemoryEntry> box, _) {

          if (box.values.isEmpty) { // Default Message if no entries yet
            return const Center(
              child: Text(
                'No memories yet. Tap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Displaying memories in a list, newest first
          List<MemoryEntry> memories = box.values.toList();
          memories.sort((a, b) => b.date.compareTo(a.date)); // To sortNewest first

          // All the cards
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      // Display Image
                      if (memory.imagePath != null && memory.imagePath!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(memory.imagePath!),
                            width: double.infinity, // The full width of card (equivalent to 100% - weird way to implement lol)
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                color: Colors.grey[300],
                                alignment: Alignment.center,
                                child: const Text('Error loading image', style: TextStyle(color: Colors.red)),
                              );
                            },
                          ),
                        ),
                      if (memory.imagePath != null && memory.imagePath!.isNotEmpty)
                        const SizedBox(height: 10),

                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(memory.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memory.caption,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Feeling: ${memory.feeling}',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (memory.textEntry != null && memory.textEntry!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            memory.textEntry!,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3, // The 3 lines is to show a short preview of the text.
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Might add "tap to View" here if I have time
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Add a new memory button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Create a New Memory')),
          // );
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