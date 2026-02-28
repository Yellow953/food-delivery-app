import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/checkout_controller.dart';
import '../../controllers/main_controller.dart';
import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: Obx(() {
        if (controller.orderPlaced.value) {
          return _OrderSuccessBody(
            orderId: controller.orderId.value,
            colorScheme: colorScheme,
            theme: theme,
          );
        }

        if (controller.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: theme.textTheme.titleMedium),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Get.back<void>(),
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Order items ---
              _SectionLabel('Your order'),
              const SizedBox(height: 12),
              _ItemsCard(),
              const SizedBox(height: 24),

              // --- Customer info ---
              _SectionLabel('Your details'),
              const SizedBox(height: 12),
              _CustomerInfoCard(controller: controller),
              const SizedBox(height: 24),

              // --- Delivery address ---
              _SectionLabel('Delivery address'),
              const SizedBox(height: 12),
              _AddressSection(controller: controller),
              const SizedBox(height: 24),

              // --- Payment method ---
              _SectionLabel('Payment method'),
              const SizedBox(height: 12),
              Obx(
                () => _PaymentCard(
                  selected: controller.paymentMethod.value,
                  onChanged: (v) => controller.paymentMethod.value = v,
                ),
              ),
              const SizedBox(height: 24),

              // --- Price summary ---
              _SectionLabel('Order summary'),
              const SizedBox(height: 12),
              _SummaryCard(controller: controller),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.orderPlaced.value || controller.isEmpty) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: FilledButton(
              onPressed: controller.isPlacingOrder.value
                  ? null
                  : controller.placeOrder,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: controller.isPlacingOrder.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Obx(
                      () => Text(
                        'Place order · \$${controller.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ── Customer info ──────────────────────────────────────────────────────────

class _CustomerInfoCard extends StatelessWidget {
  const _CustomerInfoCard({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
    );

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name
            Obx(() => TextField(
                  controller: controller.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Full name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: controller.nameError.value.isEmpty
                        ? null
                        : controller.nameError.value,
                  ),
                  onChanged: (_) {
                    if (controller.nameError.value.isNotEmpty) {
                      controller.nameError.value = '';
                    }
                  },
                )),
            const SizedBox(height: 12),
            // Phone
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: inputDecoration.copyWith(
                labelText: 'Phone number',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            // Email (read-only when pre-filled from auth)
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecoration.copyWith(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Address section ────────────────────────────────────────────────────────

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final addresses = controller.savedAddresses;
      final selectedId = controller.selectedAddressId.value;

      return Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black12,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved addresses (if any)
            if (addresses.isNotEmpty) ...[
              ...addresses.asMap().entries.map((entry) {
                final addr = entry.value;
                final isSelected = selectedId == addr.id;
                return _AddressTile(
                  address: addr,
                  isSelected: isSelected,
                  onTap: () => controller.selectAddress(addr),
                  colorScheme: colorScheme,
                  theme: theme,
                );
              }),
              // Divider before manual entry
              Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(0.4),
              ),
            ],

            // Manual entry option
            InkWell(
              onTap: controller.selectManualEntry,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_location_alt_outlined,
                        size: 20,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      addresses.isEmpty
                          ? 'Enter delivery address'
                          : 'Type a different address',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            // Address text field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.addressController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Street, city, zip code…',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: colorScheme.outline),
                      ),
                    ),
                    onChanged: (_) {
                      if (controller.addressError.value.isNotEmpty) {
                        controller.addressError.value = '';
                      }
                      // Deselect saved address when typing manually
                      if (controller.selectedAddressId.value != 'manual') {
                        controller.selectedAddressId.value = 'manual';
                      }
                    },
                  ),
                  Obx(() {
                    if (controller.addressError.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        controller.addressError.value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isSelected
                          ? colorScheme.secondary
                          : colorScheme.onSurfaceVariant)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _labelIcon(address.label),
                  size: 20,
                  color: isSelected
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      address.addressLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: address.id,
                groupValue: isSelected ? address.id : '',
                onChanged: (_) => onTap(),
                activeColor: colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
      case 'office':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }
}

// ── Cart items ─────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  const _ItemsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = Get.find<CheckoutController>();

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => Column(
          children: [
            ...cart.items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _CartItemRow(item: item, index: i),
                  if (i < cart.items.length - 1)
                    Divider(
                      height: 1,
                      color: colorScheme.outline.withOpacity(0.4),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.index});
  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = Get.find<CheckoutController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.dish.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: colorScheme.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.restaurant_rounded,
                    color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.dish.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.sizeName +
                      (item.addons.isNotEmpty
                          ? ' · ${item.addons.join(', ')}'
                          : ''),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.lineTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: () => cart.decrementItem(index),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => cart.incrementItem(index),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.secondary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: colorScheme.secondary),
        ),
      ),
    );
  }
}

// ── Payment ────────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _PaymentOption(
            icon: Icons.money_rounded,
            title: 'Cash on delivery',
            subtitle: 'Pay when your order arrives',
            value: 'cash',
            groupValue: selected,
            onChanged: onChanged,
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.4)),
          _PaymentOption(
            icon: Icons.credit_card_rounded,
            title: 'Card',
            subtitle: 'Pay now with your card',
            value: 'card',
            groupValue: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (selected
                          ? colorScheme.secondary
                          : colorScheme.onSurfaceVariant)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: (v) => onChanged(v!),
                activeColor: colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            children: [
              _SummaryRow(
                label: 'Subtotal',
                value: '\$${controller.subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'Delivery fee',
                value: '\$${controller.deliveryFee.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 14),
              Divider(color: colorScheme.outline.withOpacity(0.5)),
              const SizedBox(height: 14),
              _SummaryRow(
                label: 'Total',
                value: '\$${controller.total.toStringAsFixed(2)}',
                bold: true,
                valueColor: colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = bold
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style?.copyWith(color: valueColor)),
      ],
    );
  }
}

// ── Order success ──────────────────────────────────────────────────────────

class _OrderSuccessBody extends StatelessWidget {
  const _OrderSuccessBody({
    required this.orderId,
    required this.colorScheme,
    required this.theme,
  });

  final String orderId;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Order placed!',
            style:
                theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Your food is being prepared.\nWe\'ll notify you when it\'s on its way.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Order $orderId',
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: () {
              Get.until((route) => route.settings.name == '/home');
              Get.find<MainController>().setIndex(3);
            },
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Track my order'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () =>
                Get.until((route) => route.settings.name == '/home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Continue shopping'),
          ),
        ],
      ),
    );
  }
}
