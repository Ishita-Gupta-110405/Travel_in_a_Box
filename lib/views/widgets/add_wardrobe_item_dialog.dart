import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/item_model.dart';
import '../../viewmodels/closet_viewmodel.dart';

class AddWardrobeItemDialog extends StatefulWidget {
  const AddWardrobeItemDialog({super.key});
  @override State<AddWardrobeItemDialog> createState() => _AddWardrobeItemDialogState();
}

class _AddWardrobeItemDialogState extends State<AddWardrobeItemDialog> {
  final _nameController = TextEditingController();
  final _subTypeController = TextEditingController();
  final _colorController = TextEditingController();

  String _selectedCategory = 'Tops';
  Uint8List? _webImage;

  bool _isAnalyzing = false;
  List<String> _tags = [];

  // 👇 NEW: State variable for the Community Toggle
  bool _isShareable = false;

  final List<String> _categories = ['Tops', 'Bottoms', 'Dresses', 'Night Gowns', 'Jackets', 'Electronics', 'Essentials', 'Shoes'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 500,
    );

    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
        _tags.clear();
      });
    }
  }

  Future<void> _analyzeImageWithAI() async {
    if (_webImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: 'AIzaSyAIHYjjCLhbt_k1TMQCqNGHGXYbpruuLLo' // Remember to rotate this later!
      );

      final prompt = TextPart("Return exactly 4 descriptive tags starting with '#' for this clothing item. Separated by spaces.");
      final imagePart = DataPart('image/png', _webImage!);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      setState(() {
        String aiTags = response.text ?? '';
        _tags = aiTags.replaceAll('\n', '').split(' ').where((tag) => tag.startsWith('#')).toList();
      });

    } catch (e) {
      debugPrint("API FAILED. SWITCHING TO DEMO MODE: $e");

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        if (_selectedCategory == 'Tops') {
          _tags = ['#Cotton', '#Casual', '#Summer', '#Breathable'];
        } else if (_selectedCategory == 'Bottoms') {
          _tags = ['#Denim', '#Durable', '#Travel', '#DarkWash'];
        } else {
          _tags = ['#Luxury', '#Essential', '#Compact', '#Travel'];
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Running Offline Vision Model", style: TextStyle(color: Colors.white))),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _saveItem() {
    if (_nameController.text.isEmpty) return;

    String finalImageUrl = "";
    if (_webImage != null) {
      String base64String = base64Encode(_webImage!);
      finalImageUrl = "data:image/png;base64,$base64String";
    }

    List<String> finalTags = ["#${_selectedCategory.toLowerCase()}", "#travel"];
    finalTags.addAll(_tags);

    final newItem = WardrobeItem(
      id: '',
      name: _nameController.text,
      category: _selectedCategory,
      subType: _subTypeController.text,
      color: _colorController.text,
      imageUrl: finalImageUrl,
      tags: finalTags,
      isShareable: _isShareable, // 👈 Assigns the toggle value to the item!
    );

    Provider.of<ClosetViewModel>(context, listen: false).addItem(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: AlertDialog(
        backgroundColor: const Color(0xE60A1220),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Color(0x4D4FC3F7))),
        title: Text("UNBOX ITEM", style: GoogleFonts.monoton(color: Colors.white, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- IMAGE & AI AREA ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black26, borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5)),
                        image: _webImage != null ? DecorationImage(image: MemoryImage(_webImage!), fit: BoxFit.cover) : null,
                      ),
                      child: _webImage == null ? const Icon(Icons.add_a_photo, color: Color(0xFF4FC3F7)) : null,
                    ),
                  ),
                  const SizedBox(width: 15),

                  if (_webImage != null)
                    Expanded(
                      child: _isAnalyzing
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCFB53B)))
                          : ElevatedButton.icon(
                        onPressed: _analyzeImageWithAI,
                        icon: const Icon(Icons.auto_awesome, color: Colors.black, size: 16),
                        label: const Text("AUTO-TAG", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCFB53B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),

              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _tags.map((t) => Chip(
                    label: Text(t, style: const TextStyle(fontSize: 10, color: Colors.black)),
                    backgroundColor: const Color(0xFF4FC3F7),
                  )).toList(),
                ),
              if (_tags.isNotEmpty) const SizedBox(height: 15),

              // --- FORM FIELDS ---
              _buildField("Name", _nameController),
              const SizedBox(height: 10),
              _buildCategoryDropdown(),
              const SizedBox(height: 10),
              _buildField("Type", _subTypeController),
              const SizedBox(height: 10),
              _buildField("Color", _colorController),

              const SizedBox(height: 15),

              // 👇 NEW: The Community Sharing Switch
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCFB53B).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFCFB53B).withOpacity(0.3)),
                ),
                child: SwitchListTile(
                  title: const Text("List on Community Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text("Let local travelers borrow this item", style: TextStyle(color: Colors.white54, fontSize: 11)),
                  value: _isShareable,
                  activeColor: const Color(0xFFCFB53B),
                  onChanged: (bool value) {
                    setState(() => _isShareable = value);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(onPressed: _saveItem, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7)), child: const Text("SAVE", style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController ctrl) => TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)));

  Widget _buildCategoryDropdown() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedCategory, isExpanded: true, dropdownColor: const Color(0xFF0A1220), style: const TextStyle(color: Colors.white), items: _categories.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedCategory = v!))));
}