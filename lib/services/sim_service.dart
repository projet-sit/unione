import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:permission_handler/permission_handler.dart';

class SimService {
  static final SimCardInfo _simCardInfo = SimCardInfo();

  static Future<List<SimInfo>> getActiveSims() async {
    try {
      if (await Permission.phone.request().isGranted) {
        return await _simCardInfo.getSimInfo() ?? [];
      }
    } catch (e) {
      // Log error or handle gracefully
    }
    return [];
  }

  static Future<Set<String>> getDetectedOperators() async {
    final sims = await getActiveSims();
    final Set<String> operators = {};
    
    for (var sim in sims) {
      String name = sim.carrierName.toUpperCase();
      if (name.contains('MTN')) {
        operators.add('MTN');
      } else if (name.contains('MOOV') || name.contains('ETISALAT')) {
        operators.add('MOOV');
      } else if (name.contains('CELTIIS') || name.contains('SBIN')) {
        operators.add('CELTIIS');
      }
    }
    return operators;
  }
}
