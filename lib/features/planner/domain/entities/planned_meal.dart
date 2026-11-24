import 'package:equatable/equatable.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

enum MealSlot {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner');

  final String label;

  const MealSlot(this.label);
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime addCalendarDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}

DateTime startOfWeek(DateTime date) {
  return addCalendarDays(date, 1 - date.weekday);
}

String plannerDateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

class PlannedMeal extends Equatable {
  final DateTime date;
  final MealSlot slot;
  final MealEntity meal;

  PlannedMeal({required DateTime date, required this.slot, required this.meal})
    : date = dateOnly(date);

  String get id => '${plannerDateKey(date)}-${slot.name}';

  @override
  List<Object?> get props => [date, slot, meal];
}
