import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memoryscrapbook/models/memory_entry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p; // The p is for p.basename and p.join for storing the image

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

   // Optional image Vars
  File? _selectedImageFile;
  String? _savedImageFilePath;

  // So, when the widge is disposed, the controllers need to be cleaned up.
  @override
  void dispose() {
    _captionController.dispose();
    _textEntryController.dispose();
    super.dispose();
  }

  ///////////////////////
  // PERMISSIONS LOGIC //
  ///////////////////////

  Future<void> _pickImage(ImageSource source) async {
    Permission neededPermission;

    if (source == ImageSource.camera) {
      neededPermission = Permission.camera;
    } else {

      // Built in logic so this can deploy on Apple or Android
      if (Platform.isAndroid) {

          // NOTE -- for Android 12 and lower I would need to use Permission.storage according to API documentation.
          // I am assuming a modern usage of 13+ (15/16 is most recent as of June 2025), as it has been over 3 years since 13 released.
        neededPermission = Permission.photos;
      } else if (Platform.isIOS) {
        neededPermission = Permission.photos; // iOS always uses Permission.photos - FUTURE ADD, don't need for now.
      } else {
        // In case this app is side-loaded on some other platform, I am just gonna add this short message at bottom (snackbar)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Platform not supported for selecting an image.'))
          );
        }
        return;
      }
    }

    // Ok, now we request the permission
    var status = await neededPermission.status;

    if (status.isDenied) {
      // If never easked for permission, OR user denied it before (app cannot work without this permission so ask every time)
      status = await neededPermission.request();
    }

    if (status.isGranted) {
      try {
        final XFile? pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80); // Slightly adjust quality to force reformat
        if (pickedFile != null) {

          // Copying the image to the phone's local app directory
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String fileName = p.basename(pickedFile.path);
          final String newPath = p.join(appDir.path, fileName);
          final File copiedImage = await File(pickedFile.path).copy(newPath);

          setState(() {
            _selectedImageFile = copiedImage; // This is for the file preview
            _savedImageFilePath = copiedImage.path; // This is for actually saving it to Hive DB
          });

        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error choosing image: $e')),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission.
      // Open app settings to allow the user to grant the permission manually.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery access permanently denied. Please enable in app settings.')),
        );
      }
      await openAppSettings(); // API is found in 'permission_handler'
    } else if (status.isDenied) { // Could be as simple as parental controls.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery permission denied. Cannot select an image.')),
        );
      }
    }
  }

  ////////////////////
  // MEMORY STORAGE //
  ////////////////////

  // Using the Hive Box to store the memory locally!!
  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {  // This is a validation to ensure form is good

      // constructor
      final newMemory = MemoryEntry(
        date: DateTime.now(),
        caption: _captionController.text,
        feeling: _selectedFeeling!, // Of note, the ! is just to ensure it's not null
        textEntry: _textEntryController.text.isNotEmpty
            ? _textEntryController.text
            : null,
        imagePath: _savedImageFilePath,
      );

      // Getting this to work is simple, but was kind of tricky to learn:
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

  // Pure UX now - building out a modal to make it feel modern
  void _showImageSource(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {                         // OnTap is lick an OnClick event listener wher I add nav on selecting image
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image Preview and Picker Button
              if (_selectedImageFile != null)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _selectedImageFile!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Change Image'),
                      onPressed: () => _showImageSource(context),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Add a Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () => _showImageSource(context),
                ),
              const SizedBox(height: 20),

              // Top Caption/Memory title Field
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Memory Caption',
                  border: OutlineInputBorder(),
                  hintText: 'What\'s the memory about?',
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
                  labelText: 'Any additional thoughts to add?',
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