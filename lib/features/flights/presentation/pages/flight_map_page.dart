import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../map/flight_geojson.dart';
import '../map/plane_icon.dart';
import '../providers/flights_provider.dart';
import '../widgets/flight_info_sheet.dart';

const _sourceId = 'flights';
const _layerId = 'flights-symbols';
const _iconId = 'plane';

/// Live flight map. Aircraft are drawn as a single GeoJSON symbol layer
/// (one source, rotated icons) for performance, refreshed on a timer by
/// [flightsControllerProvider].
@RoutePage()
class FlightMapPage extends HookConsumerWidget {
  const FlightMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = getIt<AppConfig>();
    final controllerRef = useRef<MapLibreMapController?>(null);
    final styleReady = useState(false);

    final flightsAsync = ref.watch(flightsControllerProvider);

    Future<void> pushFlights() async {
      final controller = controllerRef.value;
      final view = ref.read(flightsControllerProvider).value;
      if (controller == null || !styleReady.value || view == null) return;
      await controller.setGeoJsonSource(
        _sourceId,
        flightsToGeoJson(view.flights),
      );
    }

    // Push fresh data to the map whenever the provider emits new flights.
    ref.listen(flightsControllerProvider, (previous, next) => pushFlights());

    Future<void> onStyleLoaded() async {
      final controller = controllerRef.value;
      if (controller == null) return;

      final iconBytes = await buildPlaneIcon();
      await controller.addImage(_iconId, iconBytes);

      final view = ref.read(flightsControllerProvider).value;
      await controller.addGeoJsonSource(
        _sourceId,
        flightsToGeoJson(view?.flights ?? const []),
        promoteId: 'icao24',
      );
      await controller.addSymbolLayer(
        _sourceId,
        _layerId,
        SymbolLayerProperties(
          iconImage: _iconId,
          iconRotate: [Expressions.get, 'bearing'],
          iconSize: 0.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconRotationAlignment: 'map',
        ),
      );

      styleReady.value = true;
      await pushFlights();
    }

    void onMapCreated(MapLibreMapController controller) {
      controllerRef.value = controller;
      controller.onFeatureTapped.add((point, latLng, id, layerId, _) {
        final view = ref.read(flightsControllerProvider).value;
        final flight = view?.flights
            .where((f) => f.icao24 == id)
            .firstOrNull;
        if (flight != null) {
          FlightInfoSheet.show(context, flight);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: config.mapStyleUrl,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.0, 10.0),
              zoom: 4,
            ),
            onMapCreated: onMapCreated,
            onStyleLoadedCallback: onStyleLoaded,
            trackCameraPosition: true,
          ),
          _TopBanner(flightsAsync: flightsAsync),
          if (flightsAsync.isLoading && !flightsAsync.hasValue)
            const LoadingView(),
          if (flightsAsync.hasError)
            _MapErrorOverlay(
              failure: flightsAsync.error,
              onRetry: () =>
                  ref.read(flightsControllerProvider.notifier).refresh(),
              onSwitchToMock: () =>
                  ref.read(flightsControllerProvider.notifier).switchToMock(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.surfaceVariant,
        foregroundColor: AppColors.primary,
        onPressed: () => _goToMyLocation(context, controllerRef.value),
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _goToMyLocation(
    BuildContext context,
    MapLibreMapController? controller,
  ) async {
    if (controller == null) return;
    final messenger = ScaffoldMessenger.of(context);

    if (!await Geolocator.isLocationServiceEnabled()) {
      messenger.showSnackBar(
        SnackBar(content: Text('map.locationDisabled'.tr())),
      );
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        SnackBar(content: Text('map.locationDenied'.tr())),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        8,
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner({required this.flightsAsync});

  final AsyncValue<FlightsView> flightsAsync;

  @override
  Widget build(BuildContext context) {
    final view = flightsAsync.value;
    if (view == null) return const SizedBox.shrink();

    final isFallback = view.isMockFallback;
    final isMock = view.source == DataSource.mock;
    if (!isMock) return const SizedBox.shrink();

    final label =
        isFallback ? 'map.fallbackBanner'.tr() : 'map.mockBanner'.tr();

    return SafeArea(child: MockDataBanner(label: label));
  }
}

class _MapErrorOverlay extends StatelessWidget {
  const _MapErrorOverlay({
    required this.failure,
    required this.onRetry,
    required this.onSwitchToMock,
  });

  final Object? failure;
  final VoidCallback onRetry;
  final VoidCallback onSwitchToMock;

  @override
  Widget build(BuildContext context) {
    final canFallback =
        failure is Failure && (failure! as Failure).isFallbackCandidate;

    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                failureMessage(failure),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: 'common.retry'.tr(),
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
              if (canFallback) ...[
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: onSwitchToMock,
                  child: Text('common.switchToMock'.tr()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
