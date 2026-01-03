import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/marketplace_service.dart';
import '../services/storage_service.dart';
import '../providers/current_user_provider.dart';
import '../theme/app_theme.dart';

class CreateMarketplaceItemScreen extends StatefulWidget {
  const CreateMarketplaceItemScreen({super.key});

  @override
  State<CreateMarketplaceItemScreen> createState() => _CreateMarketplaceItemScreenState();
}

class _CreateMarketplaceItemScreenState extends State<CreateMarketplaceItemScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  String? _selectedCategory;
  bool _isUploading = false;
  
  final List<String> _categories = [
    'Electronics',
    'Vehicles',
    'Furniture',
    'Property',
    'Clothing',
    'Miscellaneous',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitItem() async {
    if (_titleController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _locationController.text.isEmpty || 
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add an image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = currentUserProvider.userId;
      if (userId == null) throw Exception('User not logged in');

      // Upload image
      final imageUrl = await StorageService().uploadImage(
        file: _imageFile!, 
        folder: 'fakebook/marketplace/$userId'
      );
      
      if (imageUrl == null) throw Exception('Image upload failed');

      final price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

      await MarketplaceService().createItem(
        sellerId: userId,
        title: _titleController.text,
        price: price,
        imageUrl: imageUrl,
        location: _locationController.text,
        category: _selectedCategory!,
        description: _descriptionController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item listed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Listing',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submitItem,
            child: Text(
              'Publish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isUploading ? Colors.grey : AppTheme.facebookBlue,
              ),
            ),
          ),
        ],
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Image Picker
                   GestureDetector(
                     onTap: _pickImage,
                     child: Container(
                       height: 200,
                       decoration: BoxDecoration(
                         color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                         borderRadius: BorderRadius.circular(12),
                         image: _imageFile != null
                             ? DecorationImage(
                                 image: FileImage(_imageFile!),
                                 fit: BoxFit.cover,
                               )
                             : null,
                       ),
                       child: _imageFile == null
                           ? Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(
                                   Icons.add_a_photo,
                                   size: 40,
                                   color: isDark ? Colors.grey[400] : Colors.grey[600],
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Add Photo',
                                   style: TextStyle(
                                     color: isDark ? Colors.grey[400] : Colors.grey[600],
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ],
                             )
                           : null,
                     ),
                   ),
                   const SizedBox(height: 20),
                   
                   _buildTextField(
                     controller: _titleController,
                     label: 'Title',
                     hint: 'What are you selling?',
                     isDark: isDark,
                   ),
                   const SizedBox(height: 16),
                   _buildTextField(
                     controller: _priceController,
                     label: 'Price',
                     hint: '0.00',
                     isDark: isDark,
                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
                   ),
                   const SizedBox(height: 16),
                   
                   // Category Dropdown
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Category',
                         style: TextStyle(
                           color: isDark ? Colors.grey[400] : Colors.grey[700],
                           fontWeight: FontWeight.bold,
                           fontSize: 14,
                         ),
                       ),
                       const SizedBox(height: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12),
                         decoration: BoxDecoration(
                           color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             value: _selectedCategory,
                             isExpanded: true,
                             dropdownColor: isDark ? const Color(0xFF3A3B3C) : Colors.white,
                             hint: Text(
                               'Select Category', 
                               style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500])
                             ),
                             items: _categories.map((String value) {
                               return DropdownMenuItem<String>(
                                 value: value,
                                 child: Text(
                                   value,
                                   style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                 ),
                               );
                             }).toList(),
                             onChanged: (newValue) {
                               setState(() {
                                 _selectedCategory = newValue;
                               });
                             },
                           ),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),

                   _buildTextField(
                     controller: _locationController,
                     label: 'Location',
                     hint: 'City, Neighborhood',
                     isDark: isDark,
                   ),
                   const SizedBox(height: 16),
                   
                   _buildTextField(
                     controller: _descriptionController,
                     label: 'Description',
                     hint: 'Describe your item...',
                     isDark: isDark,
                     maxLines: 4,
                   ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
