import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/seller_product_form_controller.dart';
import '../../models/seller_product_model.dart';

class SellerProductFormView extends GetView<SellerProductFormController> {
  const SellerProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── App bar ──────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    controller.isEditing ? 'Edit Product' : 'New Product',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    Obx(() => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: controller.isSaving.value
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.primary),
                                  ),
                                )
                              : FilledButton(
                                  onPressed: controller.save,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 0),
                                    minimumSize: const Size(0, 36),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  child: const Text('Save',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                        )),
                  ],
                ),

                // ── Hero image zone ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroImageSection(controller: controller),
                ),

                // ── Error banner ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Obx(() => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _ErrorBanner(controller.errorMessage.value),
                        )),
                ),

                // ── Details ──────────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _sectionLabel(context, 'Details'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: _ShadowCard(
                    children: [
                      _FieldRow(
                        icon: Icons.label_outline_rounded,
                        child: TextField(
                          controller: controller.titleController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          decoration: _borderlessDecoration(
                              'Product name *', null),
                          onChanged: (_) => controller.clearError(),
                        ),
                      ),
                      _divider(context),
                      _FieldRow(
                        icon: Icons.notes_rounded,
                        alignIconTop: true,
                        child: TextField(
                          controller: controller.descriptionController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 4,
                          minLines: 2,
                          decoration: _borderlessDecoration(
                              'Description (optional)', null),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Category ─────────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _sectionLabel(context, 'Category'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Obx(() {
                    final cats = controller.categoryCtrl.categories;
                    if (cats.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No categories yet — add them from the Store tab.',
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cats.map((cat) {
                          final selected =
                              controller.selectedCategory.value == cat.name;
                          return _CategoryChip(
                            label: cat.name,
                            selected: selected,
                            onTap: () => controller.selectedCategory.value =
                                selected ? '' : cat.name,
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),

                // ── Pricing & availability ────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _sectionLabel(context, 'Pricing & Availability'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: _ShadowCard(
                    children: [
                      _FieldRow(
                        icon: Icons.attach_money_rounded,
                        child: TextField(
                          controller: controller.basePriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          decoration: _borderlessDecoration(
                              'Base price *', '0.00'),
                          onChanged: (_) => controller.clearError(),
                        ),
                      ),
                      _divider(context),
                      Obx(() => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  controller.isAvailable.value
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  size: 20,
                                  color: controller.isAvailable.value
                                      ? Colors.green
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Available for ordering',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        controller.isAvailable.value
                                            ? 'Visible to customers'
                                            : 'Hidden from customers',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: controller.isAvailable.value,
                                  onChanged: (v) =>
                                      controller.isAvailable.value = v,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                // ── Variants ─────────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _sectionLabelInline(context, 'Variants'),
                        const SizedBox(width: 6),
                        Text('(sizes, extras, add-ons)',
                            style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: _VariantsSection(controller: controller),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );

  static Widget _sectionLabelInline(BuildContext context, String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  static Widget _divider(BuildContext context) => Divider(
        height: 1,
        indent: 50,
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
      );

  static InputDecoration _borderlessDecoration(
          String label, String? hint) =>
      InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black38),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        isDense: true,
      );
}

// ─── Hero image zone ─────────────────────────────────────────────────────────

class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection({required this.controller});
  final SellerProductFormController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final urls = controller.imageUrls;
      final uploading = controller.isUploadingImages.value;

      return Column(
        children: [
          // Cover photo area
          GestureDetector(
            onTap: uploading ? null : controller.pickImages,
            child: Container(
              height: 220,
              color: colorScheme.surfaceContainerHighest,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image or placeholder
                  if (urls.isNotEmpty)
                    Image.network(
                      urls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(colorScheme),
                    )
                  else
                    _placeholder(colorScheme),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Upload button / spinner
                  if (uploading)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white54, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_photo_alternate_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              urls.isEmpty
                                  ? 'Add photos'
                                  : 'Add more photos',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Photo count badge
                  if (urls.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text('${urls.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Thumbnail strip (if more than 1 image)
          if (urls.length > 1) ...[
            const SizedBox(height: 1),
            Container(
              color: colorScheme.surface,
              height: 72,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: controller.reorderImage,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: urls.length,
                itemBuilder: (context, i) => ReorderableDragStartListener(
                  key: ValueKey(urls[i]),
                  index: i,
                  child: _Thumbnail(
                    url: urls[i],
                    isSelected: i == 0,
                    onRemove: () => controller.removeImage(i),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _placeholder(ColorScheme cs) => Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
      );
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail(
      {required this.url,
      required this.isSelected,
      required this.onRemove});
  final String url;
  final bool isSelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(url,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest)),
          ),
          if (isSelected)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: colorScheme.primary, width: 2.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Colors.black87, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    size: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Variants section ─────────────────────────────────────────────────────────

class _VariantsSection extends StatelessWidget {
  const _VariantsSection({required this.controller});
  final SellerProductFormController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final variants = controller.variants;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            if (variants.isNotEmpty)
              _ShadowCard(
                padding: EdgeInsets.zero,
                children: List.generate(variants.length, (i) {
                  final v = variants[i];
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                            height: 1,
                            indent: 16,
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        child: Row(
                          children: [
                            // Color dot accent
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(v.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: v.additionalPrice == 0
                                          ? Colors.green
                                              .withValues(alpha: 0.1)
                                          : colorScheme.primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      v.additionalPrice == 0
                                          ? 'Included'
                                          : '+\$${v.additionalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: v.additionalPrice == 0
                                            ? Colors.green.shade700
                                            : colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.edit_rounded,
                                  size: 17,
                                  color: colorScheme.onSurfaceVariant),
                              onPressed: () => _showVariantSheet(context,
                                  existing: v, index: i),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 17, color: colorScheme.error),
                              onPressed: () =>
                                  controller.removeVariant(i),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showVariantSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add variant'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showVariantSheet(BuildContext context,
      {ProductVariantModel? existing, int? index}) async {
    // Sheet returns the entered values via pop(); we act only after it's fully gone.
    final result = await showModalBottomSheet<(String, double)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VariantSheet(existing: existing),
    );
    if (result == null) return;
    final (name, price) = result;
    if (index != null) {
      controller.updateVariant(index, name, price);
    } else {
      controller.addVariant(name, price);
    }
  }
}

/// Stateful bottom sheet. Pops with `(name, price)` on confirm, null on cancel.
/// Controllers are disposed in [State.dispose], never via whenComplete.
class _VariantSheet extends StatefulWidget {
  const _VariantSheet({this.existing});
  final ProductVariantModel? existing;

  @override
  State<_VariantSheet> createState() => _VariantSheetState();
}

class _VariantSheetState extends State<_VariantSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existing != null && widget.existing!.additionalPrice > 0
          ? widget.existing!.additionalPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.existing != null ? 'Edit variant' : 'New variant',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          // Name field
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Name  (e.g. Small, Large, Spicy)',
                prefixIcon: Icon(Icons.label_outline_rounded,
                    color: colorScheme.primary),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Price field
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Additional price  (0.00 if included)',
                prefixIcon: Icon(Icons.add_rounded,
                    color: colorScheme.primary),
                prefixText: '\$ ',
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              widget.existing != null ? 'Save changes' : 'Add variant',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    // Pop with the result — caller processes it after sheet is fully dismissed.
    Navigator.of(context).pop((name, price));
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.children, this.padding});
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow(
      {required this.icon, required this.child, this.alignIconTop = false});
  final IconData icon;
  final Widget child;
  final bool alignIconTop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: alignIconTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignIconTop ? 16 : 0),
            child: Icon(icon,
                size: 20, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
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
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: colorScheme.onErrorContainer, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
