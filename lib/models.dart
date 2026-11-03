// lib/models.dart

enum ItemType { barcode, looseKg, loosePiece }

class ProductItem {
  String id;
  String name;
  String? barcode;
  ItemType type;
  double buyingPrice;
  double sellingPrice;
  double currentStock; // kilo ya piece
  String? imagePath;
  bool isPending;

  ProductItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.type,
    this.buyingPrice = 0.0,
    required this.sellingPrice,
    required this.currentStock,
    this.imagePath,
    this.isPending = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'type': type.name,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'imagePath': imagePath,
      'isPending': isPending,
    };
  }

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      barcode: map['barcode'],
      type: ItemType.values.byName(map['type'] ?? 'barcode'),
      buyingPrice: (map['buyingPrice'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      currentStock: (map['currentStock'] ?? 0.0).toDouble(),
      imagePath: map['imagePath'],
      isPending: map['isPending'] ?? false,
    );
  }
}

class CartItem {
  ProductItem product;
  double quantity; // Piece ya Gram/Kg
  double customPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.customPrice,
  });

  double get totalPrice => quantity * customPrice;
}

class UdhaarCustomer {
  String id;
  String name;
  String phone;
  double pendingAmount;

  UdhaarCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.pendingAmount,
  });
}

class BillRecord {
  String id;
  DateTime date;
  List<CartItem> items;
  double totalAmount;
  String paymentMode; // 'Cash', 'Online', 'Udhaar'
  String? customerName;

  BillRecord({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.paymentMode,
    this.customerName,
  });
}

