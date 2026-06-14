import '../data/ussd_data.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../models/forfait.dart';

class ComparisonGroup {
  final String price;
  final List<ReseauBundle> bundles;

  ComparisonGroup({required this.price, required this.bundles});
}

class ReseauBundle {
  final Reseau reseau;
  final Forfait forfait;
  final ActionUssd parentAction;

  ReseauBundle({
    required this.reseau, 
    required this.forfait, 
    required this.parentAction
  });
}

class ComparatorService {
  static List<ComparisonGroup> getComparisonData() {
    final Map<String, List<ReseauBundle>> groups = {};

    for (var reseau in UssdData.reseaux) {
      final reseauActions = UssdData.actions[reseau.type] ?? [];
      
      for (var action in reseauActions) {
        if (action.type == ActionType.bundle && action.forfaits != null) {
          for (var forfait in action.forfaits!) {
            final price = forfait.prix;
            if (!groups.containsKey(price)) {
              groups[price] = [];
            }
            groups[price]!.add(ReseauBundle(
              reseau: reseau,
              forfait: forfait,
              parentAction: action,
            ));
          }
        }
      }
    }

    // Convert Map to sorted List of ComparisonGroup
    final sortedPrices = groups.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    
    return sortedPrices.map((price) {
      return ComparisonGroup(
        price: price,
        bundles: groups[price]!,
      );
    }).toList();
  }
}
