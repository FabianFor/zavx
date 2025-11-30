import 'package:uuid/uuid.dart';

class Product {
  String id;
  String name;
  double price;
  String description;
  int stock;
  String imagePath;

  Product({
    String? id,
    required this.name,
    required this.price,
    this.description = '',
    this.stock = 0,
    this.imagePath = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'stock': stock,
        'imagePath': imagePath,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  Product copyWith({
    String? name,
    double? price,
    String? description,
    int? stock,
    String? imagePath,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
