import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../models/popular_dish_model.dart';

class HomeTab extends GetView<MainController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final email = controller.userEmail ?? 'Guest';
    final name = email.split('@').first;
    final greeting =
        name.length > 1 ? name[0].toUpperCase() + name.substring(1) : name;

    return Obx(() {
      final loading = controller.homeDataLoading.value;
      final promotionList = controller.banners;
      final dishList = controller.popularDishes;
      final categoryList = controller.categories;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeaderWithBubbles(
              greeting: 'Hey, $greeting',
              headline: 'Good food.\nFast delivery.',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: _SearchBar(onTap: () => controller.setIndex(1)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _SectionTitle(title: 'Promotions'),
            ),
          ),
          if (loading && promotionList.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: promotionList.length + 1,
                  itemBuilder: (_, i) {
                    if (i == promotionList.length) {
                      return const SizedBox(width: 20);
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < promotionList.length - 1 ? 12 : 0),
                      child: SizedBox(
                        width: 280,
                        height: 160,
                        child: _PromotionCard(
                          imageUrl: promotionList[i].imageUrl,
                          title: promotionList[i].title,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: _SectionTitle(title: 'Popular now'),
            ),
          ),
          if (loading && dishList.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (dishList.isEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 24))
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 308,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: dishList.length + 1,
                  itemBuilder: (_, i) {
                    if (i == dishList.length) {
                      return const SizedBox(width: 20);
                    }
                    final dish = dishList[i];
                    return Obx(() => Padding(
                          padding: EdgeInsets.only(
                              right: i < dishList.length - 1 ? 16 : 0),
                          child: SizedBox(
                            width: 280,
                            child: _PopularCard(
                              dish: dish,
                              isFavorite: controller.isFavoriteDish(dish.id),
                              onFavoriteTap: () =>
                                  controller.toggleFavoriteDish(dish.id),
                              onTap: () => Get.toNamed<void>(
                                    AppRoutes.productDetail,
                                    arguments: dish,
                                  ),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: _SectionTitle(title: 'Categories'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < categoryList.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      _CategoryCard(
                        label: categoryList[i].label,
                        icon: _iconFromName(categoryList[i].iconName),
                        color: _categoryColor(i),
                        selected: i == 0,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  static Color _categoryColor(int index) {
    const colors = [
      Color(0xFFF5A623), // orange
      Color(0xFF4CAF50), // green
      Color(0xFF2196F3), // blue
      Color(0xFFE91E63), // pink
    ];
    return colors[index % colors.length];
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'dinner_dining':
        return Icons.dinner_dining_rounded;
      case 'soup_kitchen':
        return Icons.soup_kitchen_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }
}

class _HeaderWithBubbles extends StatelessWidget {
  const _HeaderWithBubbles({
    required this.greeting,
    required this.headline,
  });

  final String greeting;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.secondary,
                colorScheme.secondary.withOpacity(0.85),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSecondary.withOpacity(0.95),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                headline,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: colorScheme.onSecondary,
                    ),
              ),
            ],
          ),
        ),
        Positioned(top: 24, right: 20, child: _Bubble(radius: 56, opacity: 0.2)),
        Positioned(top: 72, right: 48, child: _Bubble(radius: 32, opacity: 0.18)),
        Positioned(top: 100, right: 8, child: _Bubble(radius: 24, opacity: 0.15)),
        Positioned(bottom: -20, left: -24, child: _Bubble(radius: 80, opacity: 0.18)),
        Positioned(bottom: 8, left: 60, child: _Bubble(radius: 40, opacity: 0.15)),
        Positioned(bottom: 40, right: 80, child: _Bubble(radius: 28, opacity: 0.2)),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.radius, required this.opacity});

  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                'Search restaurants, dishes...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.imageUrl, this.title});

  final String imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (title != null && title!.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.dish,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.onTap,
  });

  final PopularDishModel dish;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final card = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: dish.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                      size: 40,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onFavoriteTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 24,
                          color: isFavorite
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dish.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dish.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  dish.price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    return card;
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: selected ? 3 : 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
