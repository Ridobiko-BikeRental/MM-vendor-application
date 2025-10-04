import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yumquick/view/auth/view/loginscreen.dart';
import 'package:yumquick/view/profile/bloc/userprofile_bloc.dart';
import 'package:yumquick/view/profile/bloc/userprofile_event.dart';
import 'package:yumquick/view/profile/bloc/userprofile_state.dart';
import 'package:yumquick/view/profile/model/vendormodel.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class MyprofileScreen extends StatefulWidget {
  const MyprofileScreen({super.key});

  @override
  State<MyprofileScreen> createState() => _MyprofileScreenState();
}

class _MyprofileScreenState extends State<MyprofileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    context.read<UserprofileBloc>().add(LoadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<UserprofileBloc, UserprofileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            log(state.message);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is UserLoggedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          } else if (state is UserProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            setState(() {
              _pickedImageFile = null;
            });
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is UserProfileLoaded ||
              state is UserProfileUpdated) {
            final UserModel user = (state is UserProfileLoaded)
                ? state.user
                : (state as UserProfileUpdated).user;

            // Only set once to avoid overwriting user edits
            if (_nameController.text.isEmpty) _nameController.text = user.name;
            if (_emailController.text.isEmpty) {
              _emailController.text = user.email;
            }
            if (_phoneController.text.isEmpty) {
              _phoneController.text = user.mobile;
            }
            if (_cityController.text.isEmpty) _cityController.text = user.city;
            if (_stateController.text.isEmpty) {
              _stateController.text = user.state;
            }
            if (_addressController.text.isEmpty) {
              _addressController.text = user.address;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  _buildProfileImageSection(user),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildEditableField('Full Name', _nameController),
                        const SizedBox(height: 18),
                        _buildEditableField('Email', _emailController),
                        const SizedBox(height: 18),
                        _buildEditableField('Phone Number', _phoneController),
                        const SizedBox(height: 18),
                        _buildEditableField('City', _cityController),
                        const SizedBox(height: 18),
                        _buildEditableField('State', _stateController),
                        const SizedBox(height: 18),
                        _buildEditableField('Address', _addressController),
                        const SizedBox(height: 40),
                        _buildUpdateButton(user),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProfileImageSection(UserModel user) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(70),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: _buildProfileImage(user.image),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: _showImagePickerModal,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 20,
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    if (_pickedImageFile != null) {
      return Image.file(
        _pickedImageFile!,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildDefaultProfileImage(),
      );
    } else {
      return _buildDefaultProfileImage();
    }
  }

  Widget _buildDefaultProfileImage() {
    return Image.asset(
      "assets/homepageicons/userprofile.png",
      width: 140,
      height: 140,
      fit: BoxFit.cover,
    );
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera, color: AppColors.background),
              title: Text(
                'Camera',
                style: TextStyle(color: AppColors.background),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.background),
              title: const Text(
                'Gallery',
                style: TextStyle(color: AppColors.background),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffFFF6C5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(UserModel user) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 4,
          shadowColor: Colors.deepOrangeAccent,
        ),
        onPressed: () {
          final updatedUser = user.copyWith(
            name: _nameController.text.isNotEmpty
                ? _nameController.text
                : user.name,
            email: _emailController.text.isNotEmpty
                ? _emailController.text
                : user.email,
            mobile: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : user.mobile,
            city: _cityController.text.isNotEmpty
                ? _cityController.text
                : user.city,
            state: _stateController.text.isNotEmpty
                ? _stateController.text
                : user.state,
            address: _addressController.text.isNotEmpty
                ? _addressController.text
                : user.address,
          );
          context.read<UserprofileBloc>().add(
            UpdateUserProfile(updatedUser, imageFile: _pickedImageFile),
          );
        },
        child: const Text(
          'Update Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: () {
          context.read<UserprofileBloc>().add(LogoutUser());
        },
        child: const Text('Logout'),
      ),
    );
  }
}
