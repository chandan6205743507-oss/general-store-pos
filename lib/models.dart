class Product {
  final String id;
  String name;
  double buyPrice;
  double sellPrice;
  double stock;
  bool isLoose;
  String unit;
  String? barcode;

  Product({
    required this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.isLoose = false,
    this.unit = 'piece',
    this.barcode,
  });
}

class CartItem {
  final Product product;
  double quantity;

  CartItem({required this.product, required this.quantity});

  double get total => product.sellPrice * quantity;
}

class Customer {
  final String name;
  final String phone;
  double udhaarAmount;

  Customer({required this.name, required this.phone, this.udhaarAmount = 0.0});
}

class StoreConfig {
  String storeName;
  String upiId;
  String planType; // "Rs 50 / Month" ya "Rs 549 / Year"
  bool isSubscribed;

  StoreConfig({
    this.storeName = "Damodar mahto general",
    this.upiId = "6202187843@upi",
    this.planType = "Rs 50 / Month",
    this.isSubscribed = true,
  });
}

class BillReceipt {
  final DateTime time;
  final List<CartItem> items;
  final double total;
  final String paymentMode;
  final String? customerName;

  BillReceipt({
    required this.time,
    required this.items,
    required this.total,
    required this.paymentMode,
    this.customerName,
  });
}
