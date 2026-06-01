import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../map/flight_frame_builder.dart';
import '../map/flight_geojson.dart';
import '../map/flight_palette.dart';
import '../map/plane_icon.dart';
import '../providers/flights_provider.dart';
import '../widgets/flight_info_sheet.dart';

const _sourceId = 'flights';
const _symbolLayer = 'flights-symbols';
const _clusterLayer = 'flights-clusters';
const _clusterCountLayer = 'flights-cluster-count';
const _ringLayer = 'flights-ring';
const _headingLayer = 'flights-heading';
const _iconId = 'plane';
const _selectedPointSource = 'flights-selected-point';
const _selectedLineSource = 'flights-selected-line';

/// Frames per second the interpolation loop targets. Aircraft drift slowly on
/// screen, so this is plenty smooth while keeping per-frame GeoJSON cheap.
const _frameBudget = Duration(milliseconds: 33);

/// Live flight map. Aircraft are drawn as a single clustered GeoJSON symbol
/// layer (one source, rotated + altitude-colored icons) and animated between
/// data refreshes by a [FlightFrameBuilder] driven off a [Ticker], so planes
/// glide instead of teleporting.
@RoutePage()
class FlightMapPage extends HookConsumerWidget {
  const FlightMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kept alive in the shell's IndexedStack — subscribe to the locale so the
    // HUD/legend re-localize immediately when the language changes.
    final _ = context.locale;
    final config = getIt<AppConfig>();
    final controllerRef = useRef<MapLibreMapController?>(null);
    final styleReady = useState(false);
    final selected = useState<String?>(null);

    final frameBuilder = useMemoized(FlightFrameBuilder.new);
    final ticker = useSingleTickerProvider();

    // Animation bookkeeping kept in refs so the long-lived ticker closure reads
    // the latest values without rebuilding.
    final elapsedRef = useRef(Duration.zero);
    final legStartRef = useRef(Duration.zero);
    final lastPushRef = useRef(const Duration(seconds: -1));
    final settledRef = useRef(true);
    final pushingRef = useRef(false);
    final tRef = useRef(1.0);

    final flightsAsync = ref.watch(flightsControllerProvider);

    Future<void> pushFrame(double t) async {
      final controller = controllerRef.value;
      if (controller == null || !styleReady.value || pushingRef.value) return;
      pushingRef.value = true;
      try {
        await controller.setGeoJsonSource(_sourceId, frameBuilder.buildFrame(t));
        final sel = selected.value;
        final sample = sel == null ? null : frameBuilder.sampleOf(sel, t);
        await controller.setGeoJsonSource(
          _selectedPointSource,
          selectedPointCollection(sample),
        );
        await controller.setGeoJsonSource(
          _selectedLineSource,
          headingLineCollection(sample),
        );
      } catch (_) {
        // A transient native error (e.g. style reloading) shouldn't kill the
        // animation loop; the next frame will recover.
      } finally {
        pushingRef.value = false;
      }
    }

    // Re-target the animation whenever the provider emits a fresh snapshot.
    ref.listen(flightsControllerProvider, (previous, next) {
      final flights = next.value?.flights;
      if (flights == null) return;
      frameBuilder.setTargets(flights, tRef.value);
      legStartRef.value = elapsedRef.value;
      settledRef.value = false;
      lastPushRef.value = const Duration(seconds: -1);
    });

    // Drive interpolation once the style (and thus the source/layers) exists.
    useEffect(() {
      if (!styleReady.value) return null;
      final intervalMs = config.refreshInterval.inMilliseconds;
      final t = ticker.createTicker((elapsed) {
        elapsedRef.value = elapsed;
        final progressed = (elapsed - legStartRef.value).inMilliseconds /
            (intervalMs == 0 ? 1 : intervalMs);
        final clamped = progressed.clamp(0.0, 1.0);
        tRef.value = clamped;

        if (settledRef.value && clamped >= 1.0) return;
        final due =
            (elapsed - lastPushRef.value).inMilliseconds >= _frameBudget.inMilliseconds;
        if (!due && clamped < 1.0) return;

        lastPushRef.value = elapsed;
        if (clamped >= 1.0) settledRef.value = true;
        unawaited(pushFrame(clamped));
      })..start();
      return t.dispose;
    }, [styleReady.value]);

    Future<void> onStyleLoaded() async {
      final controller = controllerRef.value;
      if (controller == null) return;

      await controller.addImage(_iconId, await buildPlaneIcon(), true);

      // Selection overlays (plain, unclustered sources).
      await controller.addGeoJsonSource(
        _selectedLineSource,
        emptyFeatureCollection(),
      );
      await controller.addGeoJsonSource(
        _selectedPointSource,
        emptyFeatureCollection(),
      );

      final view = ref.read(flightsControllerProvider).value;
      frameBuilder.setTargets(view?.flights ?? const [], 1.0);

      await controller.addSource(
        _sourceId,
        GeojsonSourceProperties(
          data: frameBuilder.buildFrame(1),
          cluster: true,
          clusterRadius: 48,
          clusterMaxZoom: 6,
          promoteId: 'icao24',
        ),
      );

      await _addLayers(controller);

      legStartRef.value = elapsedRef.value;
      settledRef.value = true;
      styleReady.value = true;
    }

    Future<void> selectFlight(BuildContext context, FlightsView view, String id) async {
      final flight = view.flights.where((f) => f.icao24 == id).firstOrNull;
      if (flight == null) return;
      await HapticFeedback.selectionClick();
      selected.value = id;
      await pushFrame(tRef.value);
      if (!context.mounted) return;
      await FlightInfoSheet.show(context, flight);
      selected.value = null;
      await pushFrame(tRef.value);
    }

    void onMapCreated(MapLibreMapController controller) {
      controllerRef.value = controller;
      controller.onFeatureTapped.add((point, latLng, id, layerId, _) {
        if (layerId == _symbolLayer) {
          final view = ref.read(flightsControllerProvider).value;
          if (view != null) unawaited(selectFlight(context, view, id.toString()));
        } else if (layerId == _clusterLayer) {
          unawaited(_zoomIntoCluster(controller, latLng));
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
          SafeArea(child: _MapHud(flightsAsync: flightsAsync)),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RefreshButton(
            isRefreshing: flightsAsync.isLoading && flightsAsync.hasValue,
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(flightsControllerProvider.notifier).refresh();
            },
          ),
          SizedBox(height: 12.h),
          FloatingActionButton(
            heroTag: 'fab-location',
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.primary,
            onPressed: () {
              HapticFeedback.lightImpact();
              _goToMyLocation(context, controllerRef.value);
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Future<void> _addLayers(MapLibreMapController controller) async {
    // Projected-track line for the selected aircraft (below everything).
    await controller.addLineLayer(
      _selectedLineSource,
      _headingLayer,
      const LineLayerProperties(
        lineColor: '#22D3EE',
        lineWidth: 2,
        lineOpacity: 0.55,
        lineCap: 'round',
      ),
      enableInteraction: false,
    );

    // Selection highlight ring.
    await controller.addCircleLayer(
      _selectedPointSource,
      _ringLayer,
      const CircleLayerProperties(
        circleRadius: [
          'interpolate',
          ['linear'],
          ['zoom'],
          3,
          12.0,
          9,
          20.0,
          13,
          30.0,
        ],
        circleColor: '#22D3EE',
        circleOpacity: 0.12,
        circleStrokeColor: '#22D3EE',
        circleStrokeWidth: 2,
      ),
      enableInteraction: false,
    );

    // Cluster bubbles.
    await controller.addCircleLayer(
      _sourceId,
      _clusterLayer,
      const CircleLayerProperties(
        circleColor: [
          'step',
          ['get', 'point_count'],
          '#22D3EE',
          25,
          '#38BDF8',
          100,
          '#7C5CFF',
        ],
        circleRadius: [
          'step',
          ['get', 'point_count'],
          16.0,
          25,
          22.0,
          100,
          28.0,
        ],
        circleOpacity: 0.85,
        circleStrokeColor: '#0A0E14',
        circleStrokeWidth: 2,
      ),
      filter: ['has', 'point_count'],
    );

    // Aircraft glyphs (unclustered points), colored by altitude.
    await controller.addSymbolLayer(
      _sourceId,
      _symbolLayer,
      const SymbolLayerProperties(
        iconImage: _iconId,
        iconRotate: ['get', 'bearing'],
        iconColor: ['get', 'color'],
        iconHaloColor: '#0A0E14',
        iconHaloWidth: 1.1,
        iconOpacity: [
          'case',
          ['get', 'onGround'],
          0.6,
          1.0,
        ],
        iconSize: [
          'interpolate',
          ['linear'],
          ['zoom'],
          3,
          0.28,
          6,
          0.42,
          9,
          0.6,
          12,
          0.85,
        ],
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconRotationAlignment: 'map',
      ),
      filter: [
        '!',
        ['has', 'point_count'],
      ],
    );

    // Cluster counts (on top).
    await controller.addSymbolLayer(
      _sourceId,
      _clusterCountLayer,
      const SymbolLayerProperties(
        textField: ['get', 'point_count_abbreviated'],
        textSize: 12,
        textColor: '#03212B',
        textHaloColor: '#22D3EE',
        textHaloWidth: 0.6,
        textAllowOverlap: true,
        textIgnorePlacement: true,
      ),
      filter: ['has', 'point_count'],
      enableInteraction: false,
    );
  }

  Future<void> _zoomIntoCluster(
    MapLibreMapController controller,
    LatLng target,
  ) async {
    await HapticFeedback.lightImpact();
    final zoom = controller.cameraPosition?.zoom ?? 5;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom + 2.5),
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

/// Refresh FAB that spins a progress ring while a refresh is in flight.
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isRefreshing, required this.onPressed});

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab-refresh',
      backgroundColor: AppColors.surfaceVariant,
      foregroundColor: AppColors.primary,
      onPressed: isRefreshing ? null : onPressed,
      child: isRefreshing
          ? SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : const Icon(Icons.refresh),
    );
  }
}

/// Floating status panel: live aircraft count, data freshness, an altitude
/// legend, and the mock-data banner when applicable.
class _MapHud extends StatelessWidget {
  const _MapHud({required this.flightsAsync});

  final AsyncValue<FlightsView> flightsAsync;

  @override
  Widget build(BuildContext context) {
    final view = flightsAsync.value;
    if (view == null) return const SizedBox.shrink();

    final isMock = view.source == DataSource.mock;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flight, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 8.w),
                      Text(
                        'map.aircraftCount'
                            .tr(args: ['${view.flights.length}']),
                        style: AppTextStyles.mono.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 1,
                        height: 14.h,
                        color: AppColors.outline,
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.schedule,
                        size: 13.sp,
                        color: AppColors.onSurfaceMuted,
                      ),
                      SizedBox(width: 4.w),
                      _LiveAgo(timestamp: view.updatedAt),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  const _AltitudeLegend(),
                ],
              ),
            ),
            if (isMock) ...[
              SizedBox(height: 8.h),
              MockDataBanner(
                label: view.isMockFallback
                    ? 'map.fallbackBanner'.tr()
                    : 'map.mockBanner'.tr(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact color key explaining the altitude-based marker colors.
class _AltitudeLegend extends StatelessWidget {
  const _AltitudeLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (labelKey, color) in FlightPalette.legend) ...[
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          Text(labelKey.tr(), style: AppTextStyles.labelSmall),
          SizedBox(width: 12.w),
        ],
      ],
    );
  }
}

/// Shows how long ago the on-screen positions were fetched, ticking each second.
class _LiveAgo extends StatefulWidget {
  const _LiveAgo({required this.timestamp});

  final DateTime timestamp;

  @override
  State<_LiveAgo> createState() => _LiveAgoState();
}

class _LiveAgoState extends State<_LiveAgo> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = DateTime.now().difference(widget.timestamp).inSeconds;
    final String label;
    if (seconds < 5) {
      label = 'map.justNow'.tr();
    } else if (seconds < 60) {
      label = 'map.secondsAgo'.tr(args: ['$seconds']);
    } else {
      label = 'map.minutesAgo'.tr(args: ['${seconds ~/ 60}']);
    }
    return Text(label, style: AppTextStyles.labelSmall);
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
