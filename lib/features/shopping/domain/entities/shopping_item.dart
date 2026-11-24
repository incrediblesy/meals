import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final int id;
  final String name;
  final String quantity;
  final bool isPurchased;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = '',
    this.isPurchased = false,
  });

  ShoppingItem copyWith({String? name, String? quantity, bool? isPurchased}) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, isPurchased];
}
