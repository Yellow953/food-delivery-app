import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Obx(() => TextField(
                          controller: controller.currentPasswordController,
                          obscureText: controller.obscureCurrent.value,
                          decoration: InputDecoration(
                            labelText: 'Current password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureCurrent.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => controller.obscureCurrent
                                  .value = !controller.obscureCurrent.value,
                            ),
                          ),
                          onChanged: (_) => controller.clearError(),
                        )),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Obx(() => TextField(
                          controller: controller.newPasswordController,
                          obscureText: controller.obscureNew.value,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            hintText: 'At least 6 characters',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureNew.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => controller.obscureNew.value =
                                  !controller.obscureNew.value,
                            ),
                          ),
                          onChanged: (_) => controller.clearError(),
                        )),
                    const SizedBox(height: 16),
                    Obx(() => TextField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.obscureConfirm.value,
                          decoration: InputDecoration(
                            labelText: 'Confirm new password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureConfirm.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => controller.obscureConfirm
                                  .value = !controller.obscureConfirm.value,
                            ),
                          ),
                          onChanged: (_) => controller.clearError(),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => FilledButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.save,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Change password'),
                )),
          ],
        ),
      ),
    );
  }
}
