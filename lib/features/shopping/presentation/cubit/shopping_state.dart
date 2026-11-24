import 'package:equatable/equatable.dart';

import '../../domain/entities/shopping_item.dart';

enum ShoppingStatus { initial, loading, ready, failure }

class ShoppingState extends Equatable {
  final ShoppingStatus status;
  final List<ShoppingItem> items;
  final bool isSaving;
  final String? error;

  const ShoppingState({
    this.status = ShoppingStatus.initial,
    this.items = const [],
    this.isSaving = false,
    this.error,
  });

  int get total => items.length;

  int get purchasedCount => items.where((item) => item.isPurchased).length;

  int get remainingCount => total - purchasedCount;

  double get progress => total == 0 ? 0.0 : purchasedCount / total;

  bool get canModify => status == ShoppingStatus.ready && !isSaving;

  List<ShoppingItem> get pendingItems =>
      items.where((item) => !item.isPurchased).toList();

  List<ShoppingItem> get purchasedItems =>
      items.where((item) => item.isPurchased).toList();

  @override
  List<Object?> get props => [status, items, isSaving, error];
}
