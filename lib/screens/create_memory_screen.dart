import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memoryscrapbook/models/memory_entry.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

// Now we build the memory screen state
class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _textEntryController = TextEditingController();

  String? _selectedFeeling;
  final List<String> _feelings = [
    '😊 Happy', '😢 Sad', '😠 Angry', '😲 Surprised',
    '😌 Calm', '😰 Anxious', '🥰 Loved', '🤔 Thoughtful',
    '🥳 Celebratory', '😴 Tired', '✨ Cozy'    // I can add countless others, these were just some examples.
  ];

  // So, when the widge is disposed, the controllers need to be cleaned up.
  @override
  void dispose() {
    _captionController.dispose();
    _textEntryController.dispose();
    super.dispose();
  }

// Using the Hive Box to store the memory locally!!
  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {  // This is a validation to ensure form is good

      final newMemory = MemoryEntry(
        date: DateTime.now(),
        caption: _captionController.text,
        feeling: _selectedFeeling!, // Of note, the ! is just to ensure it's not null
        textEntry: _textEntryController.text.isNotEmpty
            ? _textEntryController.text
            : null,
        // imagePath and audioPath will be added later
      );

      // Getting this to work:
      // Open the Hive box (if not already open)
      // Apparently it's a good practice to open box at start you will often use
      // But for now I will open here for simplicity within the small scope of this 4th sprint .
      final box = await Hive.openBox<MemoryEntry>('memories');
      // Then, we add it, await confirmation.
      await box.add(newMemory);

      // Let's show the confirmation as a UX thing
      if (mounted) { // Just confirming widget's still in the tree.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memory saved!')),
        );
        Navigator.pop(context); // Auto-nav back to home page on addiung
      }
    }
  }

// This is the main build for the create new memory screen with the full input form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Memory'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // Makes this a scroll window if overflow
        padding: const EdgeInsets.all(16.0),

        // Now, the form design
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              // Top Caption Field
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Memory Caption',
                  border: OutlineInputBorder(),
                  hintText: 'What\'s the image about?',
                ),
                // Ok adding the input validation
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a caption.';
                  }
                  return null;
                },
                maxLength: 125, // 125 characters seems fair for an image caption.
              ),
              const SizedBox(height: 22),

              // Mood Selector
              // Dropdown list - maybe add a custom at one point?
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'How are you feeling right now?',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFeeling,
                hint: const Text('Select a feeling'),
                isExpanded: true,
                items: _feelings.map((String feeling) {
                  return DropdownMenuItem<String>(
                    value: feeling,
                    child: Text(feeling),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFeeling = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a feeling.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Optional Text Entry
              TextFormField(
                controller: _textEntryController,
                decoration: const InputDecoration(
                  labelText: 'Would you like to add more thoughts? (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add more details...',
                ),
                maxLines: 5, // Allow multiple lines
                keyboardType: TextInputType.multiline,
                maxLength: 4000,
              ),
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save Memory'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _saveMemory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}