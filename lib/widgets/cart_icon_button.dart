import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';

/// Cart icon with optional badge (count). Use in app bars / headers.
class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    this.onTap,
    this.color,
    this.iconSize = 24,
  });

  final VoidCallback? onTap;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<MainController>();
      final count = controller.cartItemCount.value;
      final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

      return IconButton(
        onPressed: onTap ?? () {},
        icon: Badge(
          isLabelVisible: count > 0,
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: iconSize,
            color: effectiveColor,
          ),
        ),
      );
    });
  }
}
