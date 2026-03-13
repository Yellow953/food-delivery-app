import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_detail_controller.dart';
import '../../models/seller_product_model.dart';
import '../../widgets/cart_icon_button.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = controller.product;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Get.back<void>(),
            ),
            actions: [
              const CartIconButton(),
              GetBuilder<ProductDetailController>(
                builder: (_) => IconButton(
                  icon: Icon(
                    controller.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: controller.isFavorite
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                  onPressed: controller.toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: product.primaryImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.primaryImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GetBuilder<ProductDetailController>(builder: (_) {
                    return Text(
                      controller.variantPriceLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    );
                  }),
                  // ── Variant groups ─────────────────────────────────────
                  if (product.variantGroups.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ...product.variantGroups.asMap().entries.map(
                          (entry) => _VariantGroupSection(
                            groupIndex: entry.key,
                            group: entry.value,
                            controller: controller,
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: GetBuilder<ProductDetailController>(builder: (_) {
            return FilledButton(
              onPressed: controller.addToCart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Add to cart · ${controller.variantPriceLabel}'),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Variant group section ────────────────────────────────────────────────────

class _VariantGroupSection extends StatelessWidget {
  const _VariantGroupSection({
    required this.groupIndex,
    required this.group,
    required this.controller,
  });

  final int groupIndex;
  final ProductVariantGroup group;
  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                group.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.typeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (group.isSingle)
            GetBuilder<ProductDetailController>(
              builder: (_) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group.options.asMap().entries.map((e) {
                  final selected =
                      controller.isOptionSelected(groupIndex, e.key);
                  final extraLabel = e.value.additionalPrice > 0
                      ? ' +\$${e.value.additionalPrice.toStringAsFixed(2)}'
                      : '';
                  return ChoiceChip(
                    label: Text('${e.value.name}$extraLabel'),
                    selected: selected,
                    onSelected: (_) =>
                        controller.selectOption(groupIndex, e.key),
                    selectedColor: colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
            )
          else
            GetBuilder<ProductDetailController>(
              builder: (_) => Column(
                children: group.options.asMap().entries.map((e) {
                  final selected =
                      controller.isOptionSelected(groupIndex, e.key);
                  final extraLabel = e.value.additionalPrice > 0
                      ? '+\$${e.value.additionalPrice.toStringAsFixed(2)}'
                      : 'Included';
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) =>
                        controller.selectOption(groupIndex, e.key),
                    title: Text(e.value.name),
                    subtitle: Text(
                      extraLabel,
                      style: TextStyle(
                        color: e.value.additionalPrice > 0
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: colorScheme.secondary,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
