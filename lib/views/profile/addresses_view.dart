import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/addresses_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/address_model.dart';

class AddressesView extends GetView<AddressesController> {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back<void>(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: Obx(() {
        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No addresses saved yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a delivery address to get started.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: controller.addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return _AddressTile(
              address: address,
              onSetDefault: () => controller.setDefault(address.id),
              onDelete: () => controller.deleteAddress(address.id),
            );
          },
        );
      }),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final addressController = TextEditingController();
    String selectedLabel = 'Home';
    LatLng? pickedLatLng;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New address',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Label chips
                    Row(
                      children: ['Home', 'Work', 'Other'].map((label) {
                        final selected = selectedLabel == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            selectedColor: colorScheme.secondary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? colorScheme.onSecondary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                setState(() => selectedLabel = label),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        hintText: 'Full address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    // Location picker button / preview
                    if (pickedLatLng == null)
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx); // close sheet first
                          final dynamic result = await Get.toNamed(
                            AppRoutes.locationPicker,
                          );
                          if (result is LatLng && context.mounted) {
                            pickedLatLng = result;
                            // Re-open sheet with the picked location
                            _showAddAddressSheetWithData(
                              context,
                              addressLine: addressController.text,
                              label: selectedLabel,
                              initialLatLng: result,
                            );
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Pick location on map'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    else
                      _MapThumbnail(
                        latLng: pickedLatLng!,
                        onClear: () => setState(() => pickedLatLng = null),
                        onRePick: () async {
                          Navigator.pop(ctx);
                          final dynamic result = await Get.toNamed(
                            AppRoutes.locationPicker,
                            arguments: pickedLatLng,
                          );
                          if (result is LatLng && context.mounted) {
                            _showAddAddressSheetWithData(
                              context,
                              addressLine: addressController.text,
                              label: selectedLabel,
                              initialLatLng: result,
                            );
                          }
                        },
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final addr = addressController.text.trim();
                        if (addr.isEmpty) return;
                        controller.addAddress(
                          label: selectedLabel,
                          addressLine: addr,
                          latitude: pickedLatLng?.latitude,
                          longitude: pickedLatLng?.longitude,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save address'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Re-opens the add address sheet pre-filled after returning from map picker.
  void _showAddAddressSheetWithData(
    BuildContext context, {
    required String addressLine,
    required String label,
    required LatLng initialLatLng,
  }) {
    final addressController = TextEditingController(text: addressLine);
    String selectedLabel = label;
    LatLng pickedLatLng = initialLatLng;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New address',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: ['Home', 'Work', 'Other'].map((lbl) {
                        final selected = selectedLabel == lbl;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(lbl),
                            selected: selected,
                            selectedColor: colorScheme.secondary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? colorScheme.onSecondary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                setState(() => selectedLabel = lbl),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        hintText: 'Full address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    _MapThumbnail(
                      latLng: pickedLatLng,
                      onClear: () => setState(() {}),
                      onRePick: () async {
                        Navigator.pop(ctx);
                        final dynamic result = await Get.toNamed(
                          AppRoutes.locationPicker,
                          arguments: pickedLatLng,
                        );
                        if (result is LatLng && context.mounted) {
                          _showAddAddressSheetWithData(
                            context,
                            addressLine: addressController.text,
                            label: selectedLabel,
                            initialLatLng: result,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final addr = addressController.text.trim();
                        if (addr.isEmpty) return;
                        controller.addAddress(
                          label: selectedLabel,
                          addressLine: addr,
                          latitude: pickedLatLng.latitude,
                          longitude: pickedLatLng.longitude,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save address'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Inline map thumbnail shown in the add-address sheet when a location is set.
class _MapThumbnail extends StatelessWidget {
  const _MapThumbnail({
    required this.latLng,
    required this.onClear,
    required this.onRePick,
  });

  final LatLng latLng;
  final VoidCallback onClear;
  final VoidCallback onRePick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 16, color: colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'Location pinned',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(onPressed: onRePick, child: const Text('Change')),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 15,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.delivery.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng,
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${latLng.latitude.toStringAsFixed(6)}, '
          '${latLng.longitude.toStringAsFixed(6)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map preview
          if (address.hasCoordinates)
            SizedBox(
              height: 140,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(address.latitude!, address.longitude!),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.delivery.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(address.latitude!, address.longitude!),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 40,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    address.label == 'Work'
                        ? Icons.work_outline_rounded
                        : address.label == 'Home'
                            ? Icons.home_outlined
                            : Icons.location_on_outlined,
                    size: 20,
                    color: colorScheme.secondary,
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
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
                      const SizedBox(height: 4),
                      Text(
                        address.addressLine,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (address.hasCoordinates) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${address.latitude!.toStringAsFixed(6)}, '
                          '${address.longitude!.toStringAsFixed(6)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.7),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                      if (!address.isDefault) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onSetDefault,
                          child: Text(
                            'Set as default',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
