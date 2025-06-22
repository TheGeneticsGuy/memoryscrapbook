import 'package:hive/hive.dart';

part 'memory_entry.g.dart'; // This tells dart to generate this file

@HiveType(typeId: 0) // Unique id for the hive entry (object)
class MemoryEntry extends HiveObject {

  // MemoryEntry Class Global Variables
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String? imagePath; // file path to the local image - OPTIONAL image

  @HiveField(2)
  String caption;

  @HiveField(3)
  String feeling; // This is just a string like "anxious" "happy" cozy and so on

  @HiveField(4)
  String? textEntry; // Optional lengthy entry of details

  @HiveField(5)
  String? audioPath; // Another file path. but this time to the locally stored audio recording - OPTIONAL

  // Constructor
  MemoryEntry({
    required this.date,
    this.imagePath,
    required this.caption,
    required this.feeling,
    this.textEntry,
    this.audioPath,
  });
}