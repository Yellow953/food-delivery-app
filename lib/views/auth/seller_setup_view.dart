import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/seller_setup_controller.dart';

class SellerSetupView extends GetView<SellerSetupController> {
  const SellerSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo picker
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
                            border: Border.all(
                                color: colorScheme.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Tap to add logo',
                    style: TextStyle(fontSize: 12, color: Colors.black45)),
              ),
              const SizedBox(height: 20),
              Text(
                'Set up your business',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your restaurant so customers can find you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 36),
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: colorScheme.error, fontSize: 14),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              TextField(
                controller: controller.businessNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  hintText: 'e.g. Pizza House',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.businessTypeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cuisine / type',
                  hintText: 'e.g. Italian · Pizza',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded),
                ),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.businessAddressController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Business address',
                  hintText: '123 Main St, City',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.businessPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Business phone',
                  hintText: '+1 555 000 0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 32),
              Obx(() => FilledButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.submit,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue to dashboard'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
