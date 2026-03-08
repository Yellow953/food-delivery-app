import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds Firestore with initial data for all collections.
///
/// Collections seeded:
///   banners              – home screen promotion banners
///   popular_dishes       – global featured dishes shown on home screen
///   categories           – home screen category filter chips
///   restaurants          – restaurant list
///   restaurants/{id}/categories – per-restaurant product categories
///   restaurants/{id}/products   – per-restaurant products (new model)
///
/// Idempotent: runs once, guarded by meta/seed { done: true }.
/// Force re-seed: `SEED_FIRESTORE=force flutter run`
class FirestoreSeedService {
  FirestoreSeedService(this._firestore);

  final FirebaseFirestore _firestore;

  static const _metaSeed = 'meta/seed';
  static const _banners = 'banners';
  static const _popularDishes = 'popular_dishes';
  static const _homeCategories = 'categories';
  static const _restaurants = 'restaurants';

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> seedIfNeeded() async {
    final seedDoc = await _firestore.doc(_metaSeed).get();
    if (seedDoc.exists && seedDoc.data()?['done'] == true) return;
    await _runSeed();
  }

  Future<void> forceSeed() async {
    await _clearAll();
    await _runSeed();
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  Future<void> _clearAll() async {
    // Delete top-level collections
    for (final col in [_banners, _popularDishes, _homeCategories]) {
      final snap = await _firestore.collection(col).get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) { batch.delete(doc.reference); }
      if (snap.docs.isNotEmpty) await batch.commit();
    }

    // Delete restaurants + their sub-collections
    final restaurants = await _firestore.collection(_restaurants).get();
    for (final restaurant in restaurants.docs) {
      await _deleteSubCollection(restaurant.reference, 'categories');
      await _deleteSubCollection(restaurant.reference, 'products');
      await restaurant.reference.delete();
    }

    // Delete meta
    await _firestore.doc(_metaSeed).delete();
  }

  Future<void> _deleteSubCollection(
      DocumentReference parent, String name) async {
    final snap = await parent.collection(name).get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snap.docs) { batch.delete(doc.reference); }
    await batch.commit();
  }

  // ─── Seed ──────────────────────────────────────────────────────────────────

  Future<void> _runSeed() async {
    final batch = _firestore.batch();

    _seedBanners(batch);
    _seedPopularDishes(batch);
    _seedHomeCategories(batch);

    // Create restaurant document refs so we can reference them for sub-collections
    final restaurantRefs = List.generate(
      _restaurantData.length,
      (_) => _firestore.collection(_restaurants).doc(),
    );

    for (var i = 0; i < _restaurantData.length; i++) {
      batch.set(restaurantRefs[i], _restaurantData[i]);
    }

    batch.set(_firestore.doc(_metaSeed), {
      'done': true,
      'version': 2,
      'at': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Seed sub-collections separately (outside the main batch to keep it under 500 ops)
    for (var i = 0; i < restaurantRefs.length; i++) {
      await _seedRestaurantSubCollections(
        restaurantRefs[i],
        _restaurantCategories[i],
        _restaurantProducts[i],
      );
    }
  }

  Future<void> _seedRestaurantSubCollections(
    DocumentReference restaurantRef,
    List<Map<String, dynamic>> cats,
    List<Map<String, dynamic>> products,
  ) async {
    final batch = _firestore.batch();
    for (var i = 0; i < cats.length; i++) {
      batch.set(
        restaurantRef.collection('categories').doc(),
        {...cats[i], 'order': i},
      );
    }
    for (var i = 0; i < products.length; i++) {
      batch.set(
        restaurantRef.collection('products').doc(),
        {...products[i], 'order': i},
      );
    }
    await batch.commit();
  }

  // ─── Banners ───────────────────────────────────────────────────────────────

  void _seedBanners(WriteBatch batch) {
    final banners = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
        'title': '20% off first order',
        'order': 0,
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
        'title': 'Free delivery this week',
        'order': 1,
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
        'title': 'New restaurants near you',
        'order': 2,
      },
    ];
    for (final b in banners) {
      batch.set(_firestore.collection(_banners).doc(), b);
    }
  }

  // ─── Popular dishes (home screen featured) ─────────────────────────────────

  void _seedPopularDishes(WriteBatch batch) {
    final dishes = [
      {
        'title': 'Garlic Butter Steak',
        'subtitle': 'With asparagus',
        'price': '\$18',
        'imageUrl':
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
        'order': 0,
      },
      {
        'title': 'Grilled Salmon',
        'subtitle': 'Lemon & herbs',
        'price': '\$16',
        'imageUrl':
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500',
        'order': 1,
      },
      {
        'title': 'Margherita Pizza',
        'subtitle': 'Fresh basil & mozzarella',
        'price': '\$13',
        'imageUrl':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
        'order': 2,
      },
      {
        'title': 'Caesar Salad',
        'subtitle': 'Crispy chicken',
        'price': '\$10',
        'imageUrl':
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500',
        'order': 3,
      },
      {
        'title': 'Beef Burger',
        'subtitle': 'Double patty with fries',
        'price': '\$12',
        'imageUrl':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        'order': 4,
      },
      {
        'title': 'Spicy Tuna Roll',
        'subtitle': 'With avocado',
        'price': '\$14',
        'imageUrl':
            'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        'order': 5,
      },
    ];
    for (final d in dishes) {
      batch.set(_firestore.collection(_popularDishes).doc(), d);
    }
  }

  // ─── Home screen category chips ────────────────────────────────────────────

  void _seedHomeCategories(WriteBatch batch) {
    final cats = [
      {'label': 'Main', 'iconName': 'dinner_dining', 'order': 0},
      {'label': 'Soups', 'iconName': 'soup_kitchen', 'order': 1},
      {'label': 'Salads', 'iconName': 'eco', 'order': 2},
      {'label': 'Drinks', 'iconName': 'local_drink', 'order': 3},
    ];
    for (final c in cats) {
      batch.set(_firestore.collection(_homeCategories).doc(), c);
    }
  }

  // ─── Restaurant top-level data ─────────────────────────────────────────────

  static final _restaurantData = [
    // 0 – The Green Bowl
    {
      'name': 'The Green Bowl',
      'cuisine': 'Healthy · Salads',
      'rating': '4.8',
      'imageUrl':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop',
      'order': 0,
      'address': '123 Health St, Downtown',
      'phone': '15551234001',
      'ownerId': '',
    },
    // 1 – Pizza House
    {
      'name': 'Pizza House',
      'cuisine': 'Italian · Pizza',
      'rating': '4.6',
      'imageUrl':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=400&fit=crop',
      'order': 1,
      'address': '456 Olive Ave, Midtown',
      'phone': '15551234002',
      'ownerId': '',
    },
    // 2 – Sushi Corner
    {
      'name': 'Sushi Corner',
      'cuisine': 'Japanese · Sushi',
      'rating': '4.9',
      'imageUrl':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=400&fit=crop',
      'order': 2,
      'address': '789 Fish Lane, Harbor',
      'phone': '15551234003',
      'ownerId': '',
    },
    // 3 – Burger & Co
    {
      'name': 'Burger & Co',
      'cuisine': 'American · Burgers',
      'rating': '4.5',
      'imageUrl':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
      'order': 3,
      'address': '321 Grill Rd, Westside',
      'phone': '15551234004',
      'ownerId': '',
    },
    // 4 – Taco Fiesta
    {
      'name': 'Taco Fiesta',
      'cuisine': 'Mexican · Tacos',
      'rating': '4.7',
      'imageUrl':
          'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop',
      'order': 4,
      'address': '654 Salsa Blvd, South',
      'phone': '15551234005',
      'ownerId': '',
    },
    // 5 – Noodle Bar
    {
      'name': 'Noodle Bar',
      'cuisine': 'Asian · Noodles',
      'rating': '4.4',
      'imageUrl':
          'https://images.unsplash.com/photo-1569718212165-3a2854114c6f?w=400&h=400&fit=crop',
      'order': 5,
      'address': '987 Broth St, East',
      'phone': '15551234006',
      'ownerId': '',
    },
  ];

  // ─── Per-restaurant categories ─────────────────────────────────────────────

  static final _restaurantCategories = [
    // 0 – The Green Bowl
    [
      {'name': 'Starters'},
      {'name': 'Salads'},
      {'name': 'Mains'},
      {'name': 'Smoothies & Drinks'},
    ],
    // 1 – Pizza House
    [
      {'name': 'Starters'},
      {'name': 'Pizza'},
      {'name': 'Pasta'},
      {'name': 'Desserts'},
      {'name': 'Drinks'},
    ],
    // 2 – Sushi Corner
    [
      {'name': 'Starters'},
      {'name': 'Sushi Rolls'},
      {'name': 'Nigiri & Sashimi'},
      {'name': 'Hot Dishes'},
      {'name': 'Drinks'},
    ],
    // 3 – Burger & Co
    [
      {'name': 'Starters'},
      {'name': 'Burgers'},
      {'name': 'Sides'},
      {'name': 'Desserts'},
      {'name': 'Drinks'},
    ],
    // 4 – Taco Fiesta
    [
      {'name': 'Starters'},
      {'name': 'Tacos'},
      {'name': 'Burritos'},
      {'name': 'Sides'},
      {'name': 'Drinks'},
    ],
    // 5 – Noodle Bar
    [
      {'name': 'Starters'},
      {'name': 'Soups & Broths'},
      {'name': 'Noodle Dishes'},
      {'name': 'Rice Dishes'},
      {'name': 'Drinks'},
    ],
  ];

  // ─── Per-restaurant products ───────────────────────────────────────────────

  static final _restaurantProducts = [
    // 0 – The Green Bowl
    [
      {
        'title': 'Caesar Salad',
        'description': 'Crispy romaine, parmesan, house-made croutons & caesar dressing',
        'category': 'Salads',
        'basePrice': 10.99,
        'imageUrls': ['https://images.unsplash.com/photo-1546793665-c74683f339c1?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Large', 'additionalPrice': 3.0},
          {'name': 'Add Chicken', 'additionalPrice': 2.5},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Avocado Toast',
        'description': 'Smashed avocado on sourdough with poached egg & chilli flakes',
        'category': 'Starters',
        'basePrice': 9.50,
        'imageUrls': ['https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=600'],
        'variants': [
          {'name': 'Single', 'additionalPrice': 0},
          {'name': 'Double', 'additionalPrice': 3.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Quinoa Power Bowl',
        'description': 'Quinoa, roasted veggies, hummus, cucumber & lemon tahini',
        'category': 'Mains',
        'basePrice': 13.99,
        'imageUrls': ['https://images.unsplash.com/photo-1559847844-5315695dadae?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Add Grilled Chicken', 'additionalPrice': 3.0},
          {'name': 'Add Salmon', 'additionalPrice': 5.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Green Detox Smoothie',
        'description': 'Spinach, banana, mango, ginger & coconut water',
        'category': 'Smoothies & Drinks',
        'basePrice': 6.50,
        'imageUrls': ['https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=600'],
        'variants': [
          {'name': 'Regular (400ml)', 'additionalPrice': 0},
          {'name': 'Large (600ml)', 'additionalPrice': 2.0},
        ],
        'isAvailable': true,
      },
    ],

    // 1 – Pizza House
    [
      {
        'title': 'Margherita Pizza',
        'description': 'San Marzano tomato, fresh mozzarella, basil & extra virgin olive oil',
        'category': 'Pizza',
        'basePrice': 13.99,
        'imageUrls': ['https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600'],
        'variants': [
          {'name': 'Small (25cm)', 'additionalPrice': 0},
          {'name': 'Medium (32cm)', 'additionalPrice': 3.0},
          {'name': 'Large (40cm)', 'additionalPrice': 6.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Pepperoni Pizza',
        'description': 'Tomato sauce, mozzarella & generous pepperoni slices',
        'category': 'Pizza',
        'basePrice': 15.99,
        'imageUrls': ['https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600'],
        'variants': [
          {'name': 'Small (25cm)', 'additionalPrice': 0},
          {'name': 'Medium (32cm)', 'additionalPrice': 3.0},
          {'name': 'Large (40cm)', 'additionalPrice': 6.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Spaghetti Carbonara',
        'description': 'Spaghetti, guanciale, egg yolk, pecorino romano & black pepper',
        'category': 'Pasta',
        'basePrice': 14.50,
        'imageUrls': ['https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Large', 'additionalPrice': 3.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Garlic Bread',
        'description': 'Toasted ciabatta with garlic butter & fresh herbs',
        'category': 'Starters',
        'basePrice': 4.99,
        'imageUrls': ['https://images.unsplash.com/photo-1619531040576-f9416740661f?w=600'],
        'variants': [
          {'name': 'Plain', 'additionalPrice': 0},
          {'name': 'With Cheese', 'additionalPrice': 1.5},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Tiramisu',
        'description': 'Classic Italian dessert with mascarpone, espresso & cocoa',
        'category': 'Desserts',
        'basePrice': 7.50,
        'imageUrls': ['https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600'],
        'variants': [],
        'isAvailable': true,
      },
    ],

    // 2 – Sushi Corner
    [
      {
        'title': 'Spicy Tuna Roll',
        'description': 'Tuna, spicy mayo, cucumber & sesame seeds (8 pcs)',
        'category': 'Sushi Rolls',
        'basePrice': 13.99,
        'imageUrls': ['https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=600'],
        'variants': [
          {'name': '8 pieces', 'additionalPrice': 0},
          {'name': '16 pieces', 'additionalPrice': 12.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Rainbow Roll',
        'description': 'California roll topped with assorted sashimi (8 pcs)',
        'category': 'Sushi Rolls',
        'basePrice': 16.99,
        'imageUrls': ['https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600'],
        'variants': [
          {'name': '8 pieces', 'additionalPrice': 0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Salmon Nigiri',
        'description': 'Hand-pressed sushi rice topped with fresh Atlantic salmon (2 pcs)',
        'category': 'Nigiri & Sashimi',
        'basePrice': 6.50,
        'imageUrls': ['https://images.unsplash.com/photo-1640714878498-5c4b6e9c5a72?w=600'],
        'variants': [
          {'name': '2 pieces', 'additionalPrice': 0},
          {'name': '4 pieces', 'additionalPrice': 6.0},
          {'name': '6 pieces', 'additionalPrice': 12.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Miso Soup',
        'description': 'Traditional miso broth with tofu, seaweed & spring onion',
        'category': 'Starters',
        'basePrice': 3.50,
        'imageUrls': ['https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600'],
        'variants': [],
        'isAvailable': true,
      },
    ],

    // 3 – Burger & Co
    [
      {
        'title': 'Classic Smash Burger',
        'description': 'Double smash patty, American cheese, pickles, onion & house sauce',
        'category': 'Burgers',
        'basePrice': 12.99,
        'imageUrls': ['https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'],
        'variants': [
          {'name': 'Single patty', 'additionalPrice': 0},
          {'name': 'Double patty', 'additionalPrice': 3.0},
          {'name': 'Triple patty', 'additionalPrice': 6.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'BBQ Bacon Burger',
        'description': 'Beef patty, crispy bacon, cheddar, BBQ sauce & coleslaw',
        'category': 'Burgers',
        'basePrice': 14.99,
        'imageUrls': ['https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Double patty', 'additionalPrice': 3.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Loaded Fries',
        'description': 'Crispy fries with cheese sauce, bacon bits & jalapeños',
        'category': 'Sides',
        'basePrice': 6.99,
        'imageUrls': ['https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Large', 'additionalPrice': 2.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Chicken Wings',
        'description': 'Crispy wings tossed in your choice of sauce (6 pcs)',
        'category': 'Starters',
        'basePrice': 9.99,
        'imageUrls': ['https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600'],
        'variants': [
          {'name': 'Buffalo', 'additionalPrice': 0},
          {'name': 'BBQ', 'additionalPrice': 0},
          {'name': 'Honey Garlic', 'additionalPrice': 0},
          {'name': '12 pieces', 'additionalPrice': 9.0},
        ],
        'isAvailable': true,
      },
    ],

    // 4 – Taco Fiesta
    [
      {
        'title': 'Carne Asada Taco',
        'description': 'Grilled beef, pico de gallo, guacamole & cilantro on corn tortilla',
        'category': 'Tacos',
        'basePrice': 4.50,
        'imageUrls': ['https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=600'],
        'variants': [
          {'name': '1 taco', 'additionalPrice': 0},
          {'name': '3 tacos', 'additionalPrice': 8.0},
          {'name': '5 tacos', 'additionalPrice': 14.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Chicken Burrito',
        'description': 'Grilled chicken, rice, black beans, cheese, salsa & sour cream',
        'category': 'Burritos',
        'basePrice': 11.99,
        'imageUrls': ['https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Add Guacamole', 'additionalPrice': 1.5},
          {'name': 'Make it a Bowl', 'additionalPrice': 0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Nachos',
        'description': 'Tortilla chips, melted cheese, jalapeños, salsa & sour cream',
        'category': 'Starters',
        'basePrice': 8.99,
        'imageUrls': ['https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Add Chicken', 'additionalPrice': 2.5},
          {'name': 'Add Beef', 'additionalPrice': 3.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Churros',
        'description': 'Fried dough sticks dusted with cinnamon sugar & chocolate dip',
        'category': 'Sides',
        'basePrice': 5.99,
        'imageUrls': ['https://images.unsplash.com/photo-1624371414361-e670edf4098f?w=600'],
        'variants': [],
        'isAvailable': true,
      },
    ],

    // 5 – Noodle Bar
    [
      {
        'title': 'Tonkotsu Ramen',
        'description': 'Rich pork bone broth, chashu pork, soft egg, nori & bamboo shoots',
        'category': 'Soups & Broths',
        'basePrice': 14.99,
        'imageUrls': ['https://images.unsplash.com/photo-1569718212165-3a2854114c6f?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Large', 'additionalPrice': 3.0},
          {'name': 'Extra Egg', 'additionalPrice': 1.0},
          {'name': 'Extra Chashu', 'additionalPrice': 2.5},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Pad Thai',
        'description': 'Stir-fried rice noodles, egg, bean sprouts, peanuts & lime',
        'category': 'Noodle Dishes',
        'basePrice': 12.99,
        'imageUrls': ['https://images.unsplash.com/photo-1559314809-0d155014e29e?w=600'],
        'variants': [
          {'name': 'Tofu (V)', 'additionalPrice': 0},
          {'name': 'Chicken', 'additionalPrice': 2.0},
          {'name': 'Shrimp', 'additionalPrice': 3.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Vegetable Gyoza',
        'description': 'Pan-fried dumplings filled with cabbage, mushroom & ginger (6 pcs)',
        'category': 'Starters',
        'basePrice': 7.99,
        'imageUrls': ['https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600'],
        'variants': [
          {'name': '6 pieces', 'additionalPrice': 0},
          {'name': '12 pieces', 'additionalPrice': 7.0},
        ],
        'isAvailable': true,
      },
      {
        'title': 'Chicken Fried Rice',
        'description': 'Jasmine rice, chicken, egg, vegetables & light soy sauce',
        'category': 'Rice Dishes',
        'basePrice': 11.99,
        'imageUrls': ['https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600'],
        'variants': [
          {'name': 'Regular', 'additionalPrice': 0},
          {'name': 'Large', 'additionalPrice': 2.5},
        ],
        'isAvailable': true,
      },
    ],
  ];
}
