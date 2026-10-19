import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/features/listing/data/listing_repository.dart';
import 'package:hamyar/shared/models/listing_model.dart';

final selectedTypeProvider = StateProvider<String?>((ref) => null);
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(listingRepositoryProvider).getCategories();
});

final listingsProvider = FutureProvider.autoDispose<List<ListingModel>>((ref) async {
  final type = ref.watch(selectedTypeProvider);
  final categoryId = ref.watch(selectedCategoryProvider);

  return ref.read(listingRepositoryProvider).getListings(
        type: type,
        categoryId: categoryId,
      );
});
