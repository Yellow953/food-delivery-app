import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_seed_service.dart';
import '../../services/home_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/signup_controller.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/product_detail_controller.dart';
import '../../controllers/restaurant_menu_controller.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../controllers/change_password_controller.dart';
import '../../views/profile/change_password_view.dart';
import '../../controllers/notifications_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/seller_orders_controller.dart';
import '../../controllers/driver_orders_controller.dart';
import '../../views/splash/splash_view.dart';
import '../../views/auth/auth_view.dart';
import '../../views/auth/signup_view.dart';
import '../../views/auth/forgot_password_view.dart';
import '../../views/main_nav/main_view.dart';
import '../../views/product_detail/product_detail_view.dart';
import '../../views/restaurant_menu/restaurant_menu_view.dart';
import '../../views/checkout/checkout_view.dart';
import '../../views/profile/edit_profile_view.dart';
import '../../views/profile/addresses_view.dart';
import '../../views/profile/notifications_view.dart';
import '../../views/profile/settings_view.dart';
import '../../views/profile/location_picker_view.dart';
import '../../views/auth/seller_setup_view.dart';
import '../../views/seller/seller_main_view.dart';
import '../../views/seller/seller_order_detail_view.dart';
import '../../views/seller/seller_product_form_view.dart';
import '../../views/seller/seller_edit_business_view.dart';
import '../../views/driver/driver_main_view.dart';
import '../../controllers/seller_setup_controller.dart';
import '../../controllers/seller_store_controller.dart';
import '../../controllers/seller_category_controller.dart';
import '../../controllers/seller_dashboard_controller.dart';
import '../../controllers/seller_product_form_controller.dart';
import '../../controllers/seller_edit_business_controller.dart';

import 'app_routes.dart';

/// Central route definitions and bindings for GetX.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: SplashView.new,
    ),
    GetPage<dynamic>(
      name: AppRoutes.auth,
      page: AuthView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<AuthController>(
          () => AuthController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.signup,
      page: SignupView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SignupController>(
          () => SignupController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.forgotPassword,
      page: ForgotPasswordView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<ForgotPasswordController>(
          () => ForgotPasswordController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: MainView.new,
      binding: BindingsBuilder<void>(() {
        if (Firebase.apps.isNotEmpty) {
          Get.lazyPut<FirestoreSeedService>(
            () => FirestoreSeedService(FirebaseFirestore.instance),
          );
          Get.lazyPut<HomeRepository>(
            () => HomeRepository(
              FirebaseFirestore.instance,
              Get.find<FirestoreSeedService>(),
            ),
          );
        }
        Get.lazyPut<MainController>(
          () => MainController(
            Get.find<AuthService>(),
            Firebase.apps.isNotEmpty ? Get.find<HomeRepository>() : null,
          ),
        );
        Get.lazyPut<OrdersController>(
          () => OrdersController(
            Get.find<AuthService>(),
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.productDetail,
      page: ProductDetailView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<ProductDetailController>(
          () => ProductDetailController(Get.find<MainController>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.restaurantMenu,
      page: RestaurantMenuView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<RestaurantMenuController>(
          () => RestaurantMenuController(Get.find<MainController>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.checkout,
      page: CheckoutView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<CheckoutController>(
          () => CheckoutController(
            Get.find<AuthService>(),
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.editProfile,
      page: EditProfileView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<EditProfileController>(
          () => EditProfileController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.addresses,
      page: AddressesView.new,
    ),
    GetPage<dynamic>(
      name: AppRoutes.notifications,
      page: NotificationsView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<NotificationsController>(
          () => NotificationsController(),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.locationPicker,
      page: LocationPickerView.new,
    ),
    GetPage<dynamic>(
      name: AppRoutes.changePassword,
      page: ChangePasswordView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<ChangePasswordController>(
          () => ChangePasswordController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.sellerSetup,
      page: SellerSetupView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SellerSetupController>(
          () => SellerSetupController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.seller,
      page: SellerMainView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SellerOrdersController>(
          () => SellerOrdersController(
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
        Get.lazyPut<SellerStoreController>(
          () => SellerStoreController(
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
        Get.lazyPut<SellerCategoryController>(
          () => SellerCategoryController(
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
        Get.lazyPut<SellerDashboardController>(
          () => SellerDashboardController(
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.sellerOrderDetail,
      page: SellerOrderDetailView.new,
    ),
    GetPage<dynamic>(
      name: AppRoutes.sellerProductForm,
      page: SellerProductFormView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SellerProductFormController>(
          () => SellerProductFormController(),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.sellerEditBusiness,
      page: SellerEditBusinessView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<SellerEditBusinessController>(
          () => SellerEditBusinessController(Get.find<AuthService>()),
        );
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.driver,
      page: DriverMainView.new,
      binding: BindingsBuilder<void>(() {
        Get.lazyPut<DriverOrdersController>(
          () => DriverOrdersController(
            Get.find<AuthService>(),
            Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
          ),
        );
      }),
    ),
  ];
}
