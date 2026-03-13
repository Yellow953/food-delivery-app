import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/seller_category_controller.dart';
import '../../controllers/seller_store_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/seller_category_model.dart';
import '../../models/seller_product_model.dart';

class SellerStoreTab extends StatelessWidget {
  const SellerStoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final storeCtrl = Get.find<SellerStoreController>();
    final catCtrl = Get.find<SellerCategoryController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Store'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed<void>(AppRoutes.sellerProductForm),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add product',
          ),
        ],
      ),
      body: Obx(() {
        if (storeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ── Category filter bar ────────────────────────────────────────
            _CategoryFilterBar(storeCtrl: storeCtrl, catCtrl: catCtrl),

            // ── Product list ───────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final products = storeCtrl.filteredProducts;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront_rounded,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          storeCtrl.selectedCategory.value != null
                              ? 'No products in this category'
                              : 'No products yet',
                          style:
                              const TextStyle(color: Colors.black45),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Get.toNamed<void>(
                              AppRoutes.sellerProductForm),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add product'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) =>
                      _ProductCard(product: products[i], ctrl: storeCtrl),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Category filter bar ──────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar(
      {required this.storeCtrl, required this.catCtrl});
  final SellerStoreController storeCtrl;
  final SellerCategoryController catCtrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final cats = catCtrl.categories;
      return Container(
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // "All" chip
                  _FilterChip(
                    label: 'All',
                    selected: storeCtrl.selectedCategory.value == null,
                    onTap: () => storeCtrl.selectCategory(null),
                    onLongPress: null,
                  ),
                  const SizedBox(width: 6),
                  // Dynamic category chips
                  ...cats.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _FilterChip(
                          label: cat.name,
                          selected:
                              storeCtrl.selectedCategory.value == cat.name,
                          onTap: () =>
                              storeCtrl.selectCategory(cat.name),
                          onLongPress: () =>
                              _showCategoryMenu(context, cat, catCtrl,
                                  storeCtrl),
                        ),
                      )),
                  // Add category chip
                  _AddCategoryChip(
                    onTap: () =>
                        _showAddCategoryDialog(context, catCtrl),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ),
      );
    });
  }

  Future<void> _showCategoryMenu(
    BuildContext context,
    SellerCategoryModel cat,
    SellerCategoryController catCtrl,
    SellerStoreController storeCtrl,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    // Return an action string so we can act AFTER the sheet is fully dismissed.
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(cat.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename'),
              onTap: () => Navigator.of(sheetCtx).pop('edit'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: colorScheme.error),
              title:
                  Text('Delete', style: TextStyle(color: colorScheme.error)),
              onTap: () => Navigator.of(sheetCtx).pop('delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    // The sheet is now fully gone — safe to push another route.
    if (!context.mounted) return;
    if (action == 'edit') {
      _showEditDialog(context, cat, catCtrl);
    } else if (action == 'delete') {
      _confirmDelete(context, cat, catCtrl, storeCtrl);
    }
  }

  void _showEditDialog(BuildContext context, SellerCategoryModel cat,
      SellerCategoryController catCtrl) {
    showDialog<void>(
      context: context,
      builder: (_) => _CategoryNameDialog(
        title: 'Rename category',
        initialValue: cat.name,
        confirmLabel: 'Save',
        onConfirm: (name) => catCtrl.updateCategory(cat.id, name),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SellerCategoryModel cat,
    SellerCategoryController catCtrl,
    SellerStoreController storeCtrl,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
            '"${cat.name}" will be removed. Products in this category won\'t be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              if (storeCtrl.selectedCategory.value == cat.name) {
                storeCtrl.selectCategory(null);
              }
              catCtrl.deleteCategory(cat.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(
      BuildContext context, SellerCategoryController catCtrl) {
    showDialog<void>(
      context: context,
      builder: (_) => _CategoryNameDialog(
        title: 'New category',
        hint: 'e.g. Starters, Mains…',
        confirmLabel: 'Add',
        onConfirm: catCtrl.addCategory,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            if (onLongPress != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.more_vert_rounded,
                size: 14,
                color: selected
                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddCategoryChip extends StatelessWidget {
  const _AddCategoryChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: colorScheme.outlineVariant,
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded,
                size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text('New',
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Product card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.ctrl});
  final SellerProductModel product;
  final SellerStoreController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.primaryImage.isNotEmpty
                  ? Image.network(
                      product.primaryImage,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(colorScheme),
                    )
                  : _placeholder(colorScheme),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (product.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(product.category,
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                  if (product.variantGroups.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${product.variantGroups.length} variant group${product.variantGroups.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                            color: Colors.black38, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(product.priceLabel,
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => ctrl.toggleAvailability(product),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.isAvailable
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.edit_rounded,
                      color: colorScheme.primary,
                      onTap: () => Get.toNamed<void>(
                          AppRoutes.sellerProductForm,
                          arguments: product),
                    ),
                    const SizedBox(width: 4),
                    _IconBtn(
                      icon: Icons.delete_outline_rounded,
                      color: colorScheme.error,
                      onTap: () =>
                          _confirmDelete(context, ctrl, product),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) => Container(
        width: 64,
        height: 64,
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.fastfood_rounded,
            color: cs.onSurfaceVariant, size: 28),
      );

  void _confirmDelete(BuildContext ctx, SellerStoreController ctrl,
      SellerProductModel p) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${p.title}" from your store?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.deleteProduct(p.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// A dialog with a single text field whose [TextEditingController] is properly
/// disposed when the widget leaves the tree — not when the Future resolves.
class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.initialValue = '',
    this.hint,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;
  final String? hint;
  final void Function(String) onConfirm;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: 'Category name',
          hintText: widget.hint,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    widget.onConfirm(name);
    Navigator.of(context).pop();
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      );
}
