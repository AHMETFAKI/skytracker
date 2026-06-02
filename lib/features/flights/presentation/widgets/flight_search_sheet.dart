import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/flight_entity.dart';
import '../map/flight_palette.dart';
import '../providers/flights_provider.dart';

/// Bottom sheet that filters the currently loaded flights by callsign and
/// returns the chosen [FlightEntity] (or null). The map then centers on and
/// selects it.
class FlightSearchSheet extends ConsumerStatefulWidget {
  const FlightSearchSheet({super.key});

  static Future<FlightEntity?> show(BuildContext context) {
    return showModalBottomSheet<FlightEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const FlightSearchSheet(),
    );
  }

  @override
  ConsumerState<FlightSearchSheet> createState() => _FlightSearchSheetState();
}

class _FlightSearchSheetState extends ConsumerState<FlightSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlightEntity> _matches(List<FlightEntity> flights) {
    final q = _query.trim().toUpperCase();
    final named = flights.where((f) => f.displayCallsign != null);
    if (q.isEmpty) {
      return named.take(30).toList();
    }
    return named
        .where((f) => f.displayCallsign!.toUpperCase().contains(q))
        .take(50)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final flights = ref.watch(flightsControllerProvider).value?.flights ?? const [];
    final results = _matches(flights);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'map.searchHint'.tr(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.45.sh),
            child: results.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'map.searchEmpty'.tr(),
                        style: AppTextStyles.bodyMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: AppColors.outline, height: 1.h),
                    itemBuilder: (context, i) => _ResultTile(flight: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.flight});

  final FlightEntity flight;

  @override
  Widget build(BuildContext context) {
    final color = FlightPalette.colorFor(
      altitudeMeters: flight.altitude,
      onGround: flight.onGround,
    );
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(flight.displayCallsign ?? '', style: AppTextStyles.mono),
      subtitle: Text(flight.originCountry, style: AppTextStyles.bodyMuted),
      trailing: Icon(Icons.my_location, size: 18.sp, color: AppColors.onSurfaceMuted),
      onTap: () => Navigator.of(context).pop(flight),
    );
  }
}
