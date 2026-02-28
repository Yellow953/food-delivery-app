import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSaving.value ? null : controller.save,
              child: controller.isSaving.value
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.secondary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: colorScheme.secondary.withOpacity(0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Fields card
            Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Display name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      onChanged: (_) {
                        if (controller.error.value.isNotEmpty) {
                          controller.error.value = '';
                        }
                      },
                    ),
                    Obx(() {
                      if (controller.error.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          controller.error.value,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.error),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: controller.email,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor:
                            colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        suffixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
