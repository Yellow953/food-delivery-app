import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds Firestore with initial home data (banners, popular dishes, categories, restaurants).
///
/// Seed runs in the app: [seedIfNeeded] is called when home/restaurant data is
/// fetched (from [HomeRepository]). It only writes once—if `meta/seed` exists
/// with `done: true`, it returns immediately. To clear and re-seed, run the app
/// with env var: `SEED_FIRESTORE=force flutter run`.
class FirestoreSeedService {
  FirestoreSeedService(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _metaSeed = 'meta/seed';
  static const String _banners = 'banners';
  static const String _popularDishes = 'popular_dishes';
  static const String _categories = 'categories';
  static const String _restaurants = 'restaurants';

  /// Seeds collections if meta/seed does not exist. Idempotent (no-op if already seeded).
  /// If meta/seed exists but restaurants are missing (e.g. old seed), backfills restaurants.
  Future<void> seedIfNeeded() async {
    final seedDoc = await _firestore.doc(_metaSeed).get();
    if (seedDoc.exists && seedDoc.data()?['done'] == true) {
      // Backfill restaurants if they were added to seed after initial deploy
      final restaurantsSnap = await _firestore.collection(_restaurants).limit(1).get();
      if (restaurantsSnap.docs.isEmpty) {
        await _seedRestaurantsOnly();
      }
      return;
    }
    await _runSeed();
  }

  /// Clears existing seed data and runs seed again. Use for manual re-seed (e.g. CLI with --force).
  Future<void> forceSeed() async {
    final batch = _firestore.batch();

    for (final col in [_banners, _popularDishes, _categories, _restaurants]) {
      final snapshot = await _firestore.collection(col).get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }
    batch.delete(_firestore.doc(_metaSeed));
    await batch.commit();
    await _runSeed();
  }

  Future<void> _runSeed() async {

    final batch = _firestore.batch();

    // Promotions (banners collection)
    final promotionRefs = [
      _firestore.collection(_banners).doc(),
      _firestore.collection(_banners).doc(),
      _firestore.collection(_banners).doc(),
    ];
    batch.set(promotionRefs[0], {
      'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
      'title': '20% off first order',
      'order': 0,
    });
    batch.set(promotionRefs[1], {
      'imageUrl': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
      'title': 'Free delivery this week',
      'order': 1,
    });
    batch.set(promotionRefs[2], {
      'imageUrl': 'https://images.unsplash.com/photo-1556742111-a301367d5585?w=800',
      'title': 'Combo deals',
      'order': 2,
    });

    // Popular dishes (more for slider)
    final dishes = [
      {'title': 'Garlic Butter Steak', 'subtitle': 'With asparagus', 'price': '\$11', 'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500', 'order': 0},
      {'title': 'Chicken Quinoa', 'subtitle': 'Mediterranean bowl', 'price': '\$12', 'imageUrl': 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=500', 'order': 1},
      {'title': 'Grilled Salmon', 'subtitle': 'Lemon & herbs', 'price': '\$14', 'imageUrl': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500', 'order': 2},
      {'title': 'Caesar Salad', 'subtitle': 'Crispy chicken', 'price': '\$9', 'imageUrl': 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500', 'order': 3},
      {'title': 'Margherita Pizza', 'subtitle': 'Fresh basil', 'price': '\$13', 'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500', 'order': 4},
      {'title': 'Beef Burger', 'subtitle': 'With fries', 'price': '\$10', 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500', 'order': 5},
    ];
    for (final d in dishes) {
      batch.set(_firestore.collection(_popularDishes).doc(), d);
    }

    // Categories
    final categoryData = [
      {'label': 'Main', 'iconName': 'dinner_dining', 'order': 0},
      {'label': 'Soups', 'iconName': 'soup_kitchen', 'order': 1},
      {'label': 'Salads', 'iconName': 'eco', 'order': 2},
      {'label': 'Drinks', 'iconName': 'local_drink', 'order': 3},
    ];
    for (final data in categoryData) {
      batch.set(_firestore.collection(_categories).doc(), data);
    }

    // Restaurants (logo, address, phone for maps/share/WhatsApp)
    final restaurantData = [
      {'name': 'The Green Bowl', 'cuisine': 'Healthy · Salads', 'rating': '4.8', 'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop', 'order': 0, 'address': '123 Health St, Downtown', 'phone': '15551234001'},
      {'name': 'Pizza House', 'cuisine': 'Italian · Pizza', 'rating': '4.6', 'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=400&fit=crop', 'order': 1, 'address': '456 Olive Ave, Midtown', 'phone': '15551234002'},
      {'name': 'Sushi Corner', 'cuisine': 'Japanese · Sushi', 'rating': '4.9', 'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=400&fit=crop', 'order': 2, 'address': '789 Fish Lane, Harbor', 'phone': '15551234003'},
      {'name': 'Burger & Co', 'cuisine': 'American · Burgers', 'rating': '4.5', 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop', 'order': 3, 'address': '321 Grill Rd, Westside', 'phone': '15551234004'},
      {'name': 'Taco Fiesta', 'cuisine': 'Mexican · Tacos', 'rating': '4.7', 'imageUrl': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop', 'order': 4, 'address': '654 Salsa Blvd, South', 'phone': '15551234005'},
      {'name': 'Noodle Bar', 'cuisine': 'Asian · Noodles', 'rating': '4.4', 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a2854114c6f?w=400&h=400&fit=crop', 'order': 5, 'address': '987 Broth St, East', 'phone': '15551234006'},
    ];
    for (final data in restaurantData) {
      batch.set(_firestore.collection(_restaurants).doc(), data);
    }

    // Mark seed as done
    batch.set(_firestore.doc(_metaSeed), {'done': true, 'at': FieldValue.serverTimestamp()});

    await batch.commit();
  }

  /// Backfill only restaurants (e.g. when meta/seed existed before restaurants were added).
  Future<void> _seedRestaurantsOnly() async {
    final restaurantData = [
      {'name': 'The Green Bowl', 'cuisine': 'Healthy · Salads', 'rating': '4.8', 'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop', 'order': 0, 'address': '123 Health St, Downtown', 'phone': '15551234001'},
      {'name': 'Pizza House', 'cuisine': 'Italian · Pizza', 'rating': '4.6', 'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=400&fit=crop', 'order': 1, 'address': '456 Olive Ave, Midtown', 'phone': '15551234002'},
      {'name': 'Sushi Corner', 'cuisine': 'Japanese · Sushi', 'rating': '4.9', 'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=400&fit=crop', 'order': 2, 'address': '789 Fish Lane, Harbor', 'phone': '15551234003'},
      {'name': 'Burger & Co', 'cuisine': 'American · Burgers', 'rating': '4.5', 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop', 'order': 3, 'address': '321 Grill Rd, Westside', 'phone': '15551234004'},
      {'name': 'Taco Fiesta', 'cuisine': 'Mexican · Tacos', 'rating': '4.7', 'imageUrl': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop', 'order': 4, 'address': '654 Salsa Blvd, South', 'phone': '15551234005'},
      {'name': 'Noodle Bar', 'cuisine': 'Asian · Noodles', 'rating': '4.4', 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a2854114c6f?w=400&h=400&fit=crop', 'order': 5, 'address': '987 Broth St, East', 'phone': '15551234006'},
    ];
    final batch = _firestore.batch();
    for (final data in restaurantData) {
      batch.set(_firestore.collection(_restaurants).doc(), data);
    }
    await batch.commit();
  }
}

