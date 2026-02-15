import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_detail_controller.dart';
import '../../widgets/cart_icon_button.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dish = controller.dish;

    if (dish == null) {
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
              Obx(() => IconButton(
                    icon: Icon(
                      controller.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: controller.isFavorite
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ),
                    onPressed: controller.toggleFavorite,
                  )),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: dish.imageUrl,
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
                    dish.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dish.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GetBuilder<ProductDetailController>(builder: (_) {
                    return Row(
                      children: [
                        Text(
                          controller.variantPriceLabel,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Size',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<ProductDetailController>(builder: (_) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: List.generate(
                        ProductDetailController.sizeLabels.length,
                        (i) => ChoiceChip(
                          label: Text(
                            '${ProductDetailController.sizeLabels[i]}'
                            '${ProductDetailController.sizePriceOffsets[i] > 0 ? ' +\$${ProductDetailController.sizePriceOffsets[i].toStringAsFixed(0)}' : ''}',
                          ),
                          selected: controller.selectedSizeIndex == i,
                          onSelected: (_) => controller.selectSize(i),
                          selectedColor: colorScheme.secondaryContainer,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Text(
                    'Add-ons',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<ProductDetailController>(builder: (_) {
                    return Column(
                      children: List.generate(
                        ProductDetailController.addonLabels.length,
                        (i) => CheckboxListTile(
                          value: controller.isAddonSelected(i),
                          onChanged: (_) => controller.toggleAddon(i),
                          title: Text(
                            '${ProductDetailController.addonLabels[i]} '
                            '+\$${ProductDetailController.addonPrices[i].toStringAsFixed(2)}',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'About this dish',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A delicious choice made with fresh ingredients. Perfect for a satisfying meal.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
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
