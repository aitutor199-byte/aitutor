import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';

class ImageSolveScreen extends StatefulWidget {
  const ImageSolveScreen({super.key});

  @override
  State<ImageSolveScreen> createState() => _ImageSolveScreenState();
}

class _ImageSolveScreenState extends State<ImageSolveScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String? _extractedText;
  String? _aiResponse;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedText = null;
          _aiResponse = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Upload to Supabase Storage
      // Process with Edge Function (OCR + AI Vision)
      // This would call the image-processing Edge Function
      
      setState(() {
        _extractedText = 'Extracted text from image...';
        _aiResponse = 'AI explanation will appear here...';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Processing failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Solve'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.contain),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No image selected', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedImage != null)
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(_isProcessing ? 'Processing...' : 'Solve Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple,
                ),
              ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Card(
                color: AppTheme.lightPink,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
              ),
            if (_extractedText != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_extractedText!),
                    ],
                  ),
                ),
              ),
            ],
            if (_aiResponse != null) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.lightGreen,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_aiResponse!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
