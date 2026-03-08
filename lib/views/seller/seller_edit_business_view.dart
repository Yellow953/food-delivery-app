import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/seller_edit_business_controller.dart';

class SellerEditBusinessView extends GetView<SellerEditBusinessController> {
  const SellerEditBusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business info'),
        elevation: 0,
        actions: [
          Obx(() => TextButton(
                onPressed:
                    controller.isSaving.value ? null : controller.save,
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Obx(() {
                final uploading = controller.isUploadingLogo.value;
                final url = controller.logoUrl.value;
                return GestureDetector(
                  onTap: uploading ? null : controller.pickLogo,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage:
                            url.isNotEmpty ? NetworkImage(url) : null,
                        child: url.isEmpty
                            ? uploading
                                ? SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.primary),
                                  )
                                : Icon(Icons.store_rounded,
                                    size: 40, color: colorScheme.primary)
                            : null,
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: colorScheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('Tap to change logo',
                  style: TextStyle(fontSize: 12, color: Colors.black45)),
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: colorScheme.error, fontSize: 14),
                ),
              );
            }),
            _SectionCard(children: [
              TextField(
                controller: controller.nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Business name *',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.cuisineController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cuisine / type',
                  hintText: 'e.g. Italian · Pizza',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.addressController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            Obx(() => FilledButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.save,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
