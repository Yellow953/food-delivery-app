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
                  child: _VariantGroupsSection(controller: controller),
                ),

                // ── Bottom save button ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Obx(() => FilledButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white),
                                )
                              : Text(
                                  controller.isEditing
                                      ? 'Save changes'
                                      : 'Create product',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                        )),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

// ─── Variant groups section ───────────────────────────────────────────────────

class _VariantGroupsSection extends StatelessWidget {
  const _VariantGroupsSection({required this.controller});
  final SellerProductFormController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = controller.variantGroups;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(groups.length, (gi) =>
              _VariantGroupCard(
                key: ValueKey('group_$gi'),
                group: groups[gi],
                groupIndex: gi,
                controller: controller,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showAddGroupSheet(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add variant group'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showAddGroupSheet(BuildContext context) async {
    final result =
        await showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _VariantGroupSheet(),
    );
    if (result == null) return;
    controller.addVariantGroup(result.$1, result.$2);
  }
}

// ─── Single variant group card ────────────────────────────────────────────────

class _VariantGroupCard extends StatelessWidget {
  const _VariantGroupCard({
    super.key,
    required this.group,
    required this.groupIndex,
    required this.controller,
  });

  final ProductVariantGroup group;
  final int groupIndex;
  final SellerProductFormController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Group header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  // Edit group name
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.edit_rounded,
                        size: 16, color: colorScheme.onSurfaceVariant),
                    onPressed: () =>
                        _showEditGroupSheet(context),
                  ),
                  // Delete group
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 16, color: colorScheme.error),
                    onPressed: () =>
                        controller.removeVariantGroup(groupIndex),
                  ),
                ],
              ),
            ),

            // ── Single / Multiple type toggle ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _TypeChip(
                    label: 'Single choice',
                    icon: Icons.radio_button_checked_rounded,
                    selected: group.isSingle,
                    onTap: () =>
                        controller.setGroupType(groupIndex, 'single'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Multiple choice',
                    icon: Icons.check_box_rounded,
                    selected: !group.isSingle,
                    onTap: () =>
                        controller.setGroupType(groupIndex, 'multiple'),
                  ),
                ],
              ),
            ),

            Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

            // ── Options list ──────────────────────────────────────────
            ...List.generate(group.options.length, (oi) {
              final opt = group.options[oi];
              return Column(
                children: [
                  if (oi > 0)
                    Divider(
                        height: 1,
                        indent: 48,
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.4)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      children: [
                        Icon(
                          group.isSingle
                              ? Icons.radio_button_unchecked_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(opt.name,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        _PriceBadge(option: opt, colorScheme: colorScheme),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.edit_rounded,
                              size: 15,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () =>
                              _showEditOptionSheet(context, oi, opt),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.close_rounded,
                              size: 15, color: colorScheme.error),
                          onPressed: () =>
                              controller.removeOption(groupIndex, oi),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            // ── Add option button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: TextButton.icon(
                onPressed: () => _showAddOptionSheet(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add option',
                    style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditGroupSheet(BuildContext context) async {
    final result =
        await showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _VariantGroupSheet(existingName: group.name, existingType: group.type),
    );
    if (result == null) return;
    controller.updateVariantGroup(groupIndex, result.$1, result.$2);
  }

  Future<void> _showAddOptionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<(String, double)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _OptionSheet(),
    );
    if (result == null) return;
    controller.addOption(groupIndex, result.$1, result.$2);
  }

  Future<void> _showEditOptionSheet(
      BuildContext context, int optionIndex, ProductVariantOption opt) async {
    final result = await showModalBottomSheet<(String, double)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(existing: opt),
    );
    if (result == null) return;
    controller.updateOption(groupIndex, optionIndex, result.$1, result.$2);
  }
}

class _PriceBadge extends StatelessWidget {
  const _PriceBadge({required this.option, required this.colorScheme});
  final ProductVariantOption option;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final free = option.additionalPrice == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: free
            ? Colors.green.withValues(alpha: 0.1)
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        option.priceLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: free ? Colors.green.shade700 : colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
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
            Icon(icon,
                size: 14,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheets ────────────────────────────────────────────────────────────

/// Sheet to create/edit a variant group (name + type).
class _VariantGroupSheet extends StatefulWidget {
  const _VariantGroupSheet({this.existingName, this.existingType});
  final String? existingName;
  final String? existingType;

  @override
  State<_VariantGroupSheet> createState() => _VariantGroupSheetState();
}

class _VariantGroupSheetState extends State<_VariantGroupSheet> {
  late final TextEditingController _nameCtrl;
  late String _type;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingName ?? '');
    _type = widget.existingType ?? 'single';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.existingName != null;
    return _Sheet(
      title: isEditing ? 'Edit variant group' : 'New variant group',
      confirmLabel: isEditing ? 'Save' : 'Add group',
      onConfirm: () {
        if (_nameCtrl.text.trim().isEmpty) return;
        Navigator.of(context).pop((_nameCtrl.text.trim(), _type));
      },
      children: [
        _SheetField(
          controller: _nameCtrl,
          hint: 'Group name  (e.g. Size, Extras, Sauce)',
          icon: Icons.label_outline_rounded,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        Text('Customer selection type',
            style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (_, setState) => Row(
            children: [
              Expanded(
                child: _TypeTile(
                  icon: Icons.radio_button_checked_rounded,
                  title: 'Single choice',
                  subtitle: 'Pick exactly one',
                  selected: _type == 'single',
                  onTap: () => setState(() => _type = 'single'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeTile(
                  icon: Icons.check_box_rounded,
                  title: 'Multiple choice',
                  subtitle: 'Pick many',
                  selected: _type == 'multiple',
                  onTap: () => setState(() => _type = 'multiple'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sheet to add/edit an option inside a group.
class _OptionSheet extends StatefulWidget {
  const _OptionSheet({this.existing});
  final ProductVariantOption? existing;

  @override
  State<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<_OptionSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.existing?.name ?? '');
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
    final isEditing = widget.existing != null;
    return _Sheet(
      title: isEditing ? 'Edit option' : 'New option',
      confirmLabel: isEditing ? 'Save' : 'Add option',
      onConfirm: () {
        if (_nameCtrl.text.trim().isEmpty) return;
        final price =
            double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
        Navigator.of(context).pop((_nameCtrl.text.trim(), price));
      },
      children: [
        _SheetField(
          controller: _nameCtrl,
          hint: 'Option name  (e.g. Small, Spicy, Extra Cheese)',
          icon: Icons.label_outline_rounded,
          autofocus: true,
        ),
        const SizedBox(height: 12),
        _SheetField(
          controller: _priceCtrl,
          hint: 'Additional price  (leave blank if included)',
          icon: Icons.add_rounded,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          prefixText: '\$ ',
        ),
      ],
    );
  }
}

/// Shared bottom sheet chrome.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    required this.children,
  });
  final String title;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final List<Widget> children;

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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(confirmLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.prefixText,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? prefixText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          prefixText: prefixText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10,
                    color: selected
                        ? colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7)
                        : colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.children});
  final List<Widget> children;

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
          padding: const EdgeInsets.symmetric(vertical: 4),
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
