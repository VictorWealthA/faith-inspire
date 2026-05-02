import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/models/inspiration_catalog.dart';
import 'core/models/daily_engagement_state.dart';
import 'core/models/inspiration_item.dart';
import 'features/content/inspiration_catalog_provider.dart';
import 'features/daily/daily_engagement_provider.dart';
import 'features/daily/daily_reflection_provider.dart';
import 'features/daily/widget_launch_provider.dart';
import 'features/favorites/favorite_ids_provider.dart';
import 'features/favorites/favorites_provider.dart';
import 'features/quotes/quotes_provider.dart';
import 'features/affirmations/affirmations_provider.dart';
import 'features/scriptures/scriptures_provider.dart';
import 'features/settings/app_settings.dart';
import 'features/settings/settings_provider.dart';
import 'screens/onboarding_sheet.dart';
import 'screens/settings_screen.dart';
import 'services/favorites_service.dart';
import 'services/daily_engagement_service.dart';
import 'services/home_widget_service.dart';
import 'services/inspiration_content_service.dart';
import 'services/notifications_service.dart';
import 'services/settings_service.dart';
import 'services/share_service.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';
import 'widgets/inspiration_card.dart';
import 'widgets/animated_gradient_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final favoritesService = FavoritesService();
  final settingsService = SettingsService();
  final notificationsService = NotificationsService();
  final dailyEngagementService = DailyEngagementService();
  final homeWidgetService = HomeWidgetService();
  final contentService = InspirationContentService();
  var catalog = const InspirationCatalog();
  var initialFavoriteIds = const <String>{};
  var initialSettings = const AppSettings();
  var initialDailyEngagement = const DailyEngagementState();

  await notificationsService.initialize();
  await homeWidgetService.initialize();

  try {
    initialSettings = await settingsService.load();
  } catch (_) {}

  try {
    catalog = await contentService.loadCatalog();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'faith_inspire',
        context: ErrorDescription('while loading inspiration content'),
      ),
    );
  }

  try {
    initialFavoriteIds = (await favoritesService.loadFavorites()).toSet();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'faith_inspire',
        context: ErrorDescription('while loading saved favorites'),
      ),
    );
  }

  try {
    initialDailyEngagement = await dailyEngagementService.recordVisit();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'faith_inspire',
        context: ErrorDescription('while recording daily engagement'),
      ),
    );
  }

  final initialDailyReflection = selectDailyReflection(catalog.allItems);

  if (initialSettings.remindersEnabled) {
    await notificationsService.scheduleDailyReminder(
      hour: initialSettings.reminderHour,
      minute: initialSettings.reminderMinute,
      items: catalog.allItems,
    );
  }

  await homeWidgetService.updateDailyReflectionWidget(
    item: initialDailyReflection,
    streakCount: initialDailyEngagement.streakCount,
  );

  runApp(
    ProviderScope(
      overrides: [
        inspirationCatalogProvider.overrideWithValue(catalog),
        favoritesServiceProvider.overrideWithValue(favoritesService),
        initialFavoriteIdsProvider.overrideWithValue(initialFavoriteIds),
        settingsServiceProvider.overrideWithValue(settingsService),
        notificationsServiceProvider.overrideWithValue(notificationsService),
        homeWidgetServiceProvider.overrideWithValue(homeWidgetService),
        dailyEngagementProvider.overrideWithValue(initialDailyEngagement),
        settingsProvider.overrideWith(
          (ref) => SettingsNotifier(
            service: ref.watch(settingsServiceProvider),
            initialSettings: initialSettings,
          ),
        ),
        activePaceProvider.overrideWith((ref) => initialSettings.defaultPace),
      ],
      child: const FaithInspireApp(),
    ),
  );
}

class FaithInspireApp extends StatelessWidget {
  const FaithInspireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faith Inspire',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _hasQueuedOnboarding = false;
  StreamSubscription<Uri?>? _widgetLaunchSubscription;

  final List<Widget> _screens = const [
    InspirationScreen(
      title: 'Quotes',
      providerType: InspirationProviderType.quotes,
    ),
    InspirationScreen(
      title: 'Affirmations',
      providerType: InspirationProviderType.affirmations,
    ),
    InspirationScreen(
      title: 'Scriptures',
      providerType: InspirationProviderType.scriptures,
    ),
    InspirationScreen(
      title: 'Favorites',
      providerType: InspirationProviderType.favorites,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Quotes';
      case 1:
        return 'Affirmations';
      case 2:
        return 'Scriptures';
      case 3:
        return 'Favorites';
      default:
        return 'Faith Inspire';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _hasQueuedOnboarding) {
        return;
      }

      final settings = ref.read(settingsProvider);
      if (settings.hasSeenOnboarding) {
        return;
      }

      _hasQueuedOnboarding = true;
      await OnboardingSheet.show(
        context,
        onStart: () {
          ref.read(settingsProvider.notifier).markOnboardingSeen();
          Navigator.of(context).pop();
        },
      );
    });

    unawaited(_configureWidgetLaunchHandling());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final milestone = ref.read(dailyEngagementProvider).recentMilestone;
      if (milestone != null && mounted) {
        _showMilestoneCelebration(milestone);
      }
    });
  }

  Future<void> _configureWidgetLaunchHandling() async {
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _handleWidgetLaunchUri(initialUri);

    _widgetLaunchSubscription = HomeWidget.widgetClicked.listen(
      _handleWidgetLaunchUri,
    );
  }

  void _handleWidgetLaunchUri(Uri? uri) {
    if (!mounted || uri == null) {
      return;
    }

    final tab = uri.queryParameters['tab'];
    final itemId = uri.queryParameters['itemId'];

    if (itemId != null && itemId.isNotEmpty) {
      ref.read(widgetLaunchItemIdProvider.notifier).state = itemId;
    }

    switch (tab) {
      case 'quotes':
        _onItemTapped(0);
        break;
      case 'affirmations':
        _onItemTapped(1);
        break;
      case 'scriptures':
        _onItemTapped(2);
        break;
      case 'favorites':
        _onItemTapped(3);
        break;
      default:
        break;
    }
  }

  _MilestoneContent _milestoneContent(int milestone) {
    switch (milestone) {
      case 7:
        return const _MilestoneContent(
          title: '7-day streak',
          message:
              'One full week of showing up. Keep this gentle rhythm going.',
        );
      case 30:
        return const _MilestoneContent(
          title: '30-day streak',
          message:
              'A full month of consistency. Your daily pause is becoming a real habit.',
        );
      case 100:
        return const _MilestoneContent(
          title: '100-day streak',
          message:
              'This is rare discipline. You have built something steady and strong.',
        );
      default:
        return _MilestoneContent(
          title: '$milestone-day streak',
          message:
              'You kept showing up. That consistency matters more than intensity.',
        );
    }
  }

  void _showMilestoneCelebration(int milestone) {
    final content = _milestoneContent(milestone);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: 38,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.88),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Keep Going'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _widgetLaunchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyReflection = ref.watch(dailyReflectionProvider);
    final dailyEngagement = ref.watch(dailyEngagementProvider);

    return Stack(
      children: [
        AnimatedGradientBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(_title, style: theme.appBarTheme.titleTextStyle),
            centerTitle: true,
            backgroundColor: theme.appBarTheme.backgroundColor?.withValues(
              alpha: 0.85,
            ),
            elevation: theme.appBarTheme.elevation,
            iconTheme: theme.appBarTheme.iconTheme,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Settings',
                onPressed: () => SettingsScreen.show(context),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (dailyReflection != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: _DailyReflectionBanner(
                      item: dailyReflection,
                      streakCount: dailyEngagement.streakCount,
                      onTap: () => _onItemTapped(_tabIndexForType(dailyReflection.type)),
                    ),
                  ),
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.format_quote),
                        label: 'Quotes',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.volume_up_rounded),
                        label: 'Affirmations',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.menu_book),
                        label: 'Scriptures',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bookmarks),
                        label: 'Favorites',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _tabIndexForType(InspirationType type) {
    switch (type) {
      case InspirationType.quote:
        return 0;
      case InspirationType.affirmation:
        return 1;
      case InspirationType.scripture:
        return 2;
    }
  }
}

class _MilestoneContent {
  final String title;
  final String message;

  const _MilestoneContent({
    required this.title,
    required this.message,
  });
}

enum InspirationProviderType {
  quotes,
  affirmations,
  scriptures,
  favorites,
}

// SlideshowPace is defined in lib/theme/app_theme.dart

class InspirationScreen extends ConsumerStatefulWidget {
  final String title;
  final InspirationProviderType providerType;

  const InspirationScreen({
    super.key,
    required this.title,
    required this.providerType,
  });

  @override
  ConsumerState<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends ConsumerState<InspirationScreen> {
  final PageController _pageController = PageController();
  final TtsService _ttsService = TtsService();
  final ShareService _shareService = ShareService();

  final Map<int, GlobalKey> _cardKeys = {};
  bool _slideshow = true;
  int _currentPage = 0;
  Timer? _slideshowTimer;
  late final ValueNotifier<bool> _userInteracted;
  late bool _readAloudEnabled;
  int _speechRequestId = 0;
  bool _isReadingCurrentItem = false;
  late SlideshowPace _slideshowPace;

  Duration get _slideDelay {
    switch (_slideshowPace) {
      case SlideshowPace.fast:
        return const Duration(seconds: 3);
      case SlideshowPace.normal:
        return const Duration(seconds: 5);
      case SlideshowPace.slow:
        return const Duration(seconds: 8);
    }
  }

  Duration get _postReadDelay {
    switch (_slideshowPace) {
      case SlideshowPace.fast:
        return const Duration(milliseconds: 450);
      case SlideshowPace.normal:
        return const Duration(milliseconds: 900);
      case SlideshowPace.slow:
        return const Duration(milliseconds: 1400);
    }
  }

  String get _slideshowPaceLabel {
    switch (_slideshowPace) {
      case SlideshowPace.fast:
        return 'Fast';
      case SlideshowPace.normal:
        return 'Normal';
      case SlideshowPace.slow:
        return 'Slow';
    }
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _readAloudEnabled = (widget.providerType != InspirationProviderType.favorites) &&
        settings.defaultReadAloud;
    _slideshowPace = settings.defaultPace;
    _userInteracted = ValueNotifier(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isSlideshowActive || _slideshowTimer != null) {
        return;
      }
      _startSlideshow();
    });
  }

  ProviderListenable<List<InspirationItem>> get _provider {
    switch (widget.providerType) {
      case InspirationProviderType.quotes:
        return quotesProvider;
      case InspirationProviderType.affirmations:
        return affirmationsProvider;
      case InspirationProviderType.scriptures:
        return scripturesProvider;
      case InspirationProviderType.favorites:
        return favoritesProvider;
    }
  }

  String _filePrefixForItem(InspirationItem item) {
    switch (item.type) {
      case InspirationType.quote:
        return 'quote';
      case InspirationType.affirmation:
        return 'affirmation';
      case InspirationType.scripture:
        return 'scripture';
    }
  }

  void _toggleFavorite(InspirationItem item) {
    ref.read(favoriteIdsProvider.notifier).toggleFavorite(item.id);
  }

  bool get _isSlideshowActive => _slideshow && !_userInteracted.value;

  Future<void> _speakItem(InspirationItem item) async {
    final requestId = ++_speechRequestId;
    _isReadingCurrentItem = true;
    await _ttsService.stop();

    if (!mounted || !_readAloudEnabled || requestId != _speechRequestId) {
      _isReadingCurrentItem = false;
      return;
    }

    try {
      await _ttsService.speak(item.text);
    } catch (error) {
      if (!mounted || !_readAloudEnabled || requestId != _speechRequestId) {
        _isReadingCurrentItem = false;
        return;
      }
      _showTtsError(error);
    } finally {
      if (requestId == _speechRequestId) {
        _isReadingCurrentItem = false;
        if (mounted && _readAloudEnabled && _isSlideshowActive) {
          _scheduleNextSlide(_postReadDelay);
        }
      }
    }
  }

  void _showTtsError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _syncPageIndex(List<InspirationItem> items) {
    if (items.isEmpty) {
      _currentPage = 0;
      return;
    }

    if (_currentPage < items.length) {
      return;
    }

    _currentPage = items.length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.jumpToPage(_currentPage);
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    _userInteracted.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _shareCard({
    required GlobalKey key,
    required String fileName,
  }) async {
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject is! RenderRepaintBoundary) {
      return;
    }

    final image = await renderObject.toImage(pixelRatio: 3.0);

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      return;
    }

    await _shareService.shareImage(
      byteData.buffer.asUint8List(),
      fileName: fileName,
    );
  }

  void _scheduleNextSlide(Duration delay) {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer(delay, () {
      _slideshowTimer = null;
      _advanceSlideshow();
    });
  }

  void _startSlideshow() {
    _scheduleNextSlide(_slideDelay);
  }

  void _advanceSlideshow() {
    if (!_isSlideshowActive || !mounted) {
      return;
    }

    final items = ref.read(_provider);
    if (items.isEmpty || !_pageController.hasClients) {
      return;
    }

    if (_readAloudEnabled && _isReadingCurrentItem) {
      return;
    }

    if (_currentPage >= items.length - 1) {
      // Jump on wrap-around to avoid long animated traversal that can desync readout.
      _pageController.jumpToPage(0);
    } else {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: AppMotion.slideshowPage,
        curve: AppMotion.standardCurve,
      );
    }

    if (!_readAloudEnabled) {
      _scheduleNextSlide(_slideDelay);
    }
  }

  void _cycleSlideshowPace() {
    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _slideshowPace = switch (_slideshowPace) {
        SlideshowPace.fast => SlideshowPace.normal,
        SlideshowPace.normal => SlideshowPace.slow,
        SlideshowPace.slow => SlideshowPace.fast,
      };
    });

    ref.read(activePaceProvider.notifier).state = _slideshowPace;

    if (_isSlideshowActive && !_readAloudEnabled) {
      _startSlideshow();
    }
  }

  void _toggleSlideshow() {
    setState(() {
      if (_isSlideshowActive) {
        _slideshow = false;
        _userInteracted.value = false;
        _slideshowTimer?.cancel();
        _slideshowTimer = null;
        return;
      }

      _slideshow = true;
      _userInteracted.value = false;
      _startSlideshow();
    });
  }

  void _syncSlideshow(List<InspirationItem> items) {
    final canAutoplay =
      _slideshow && !_userInteracted.value && items.isNotEmpty;

    if (!canAutoplay) {
      _slideshowTimer?.cancel();
      _slideshowTimer = null;
      return;
    }

    if (_slideshowTimer == null) {
      if (_readAloudEnabled) {
        if (!_isReadingCurrentItem) {
          unawaited(_speakItem(items[_currentPage]));
        }
      } else {
        _startSlideshow();
      }
    }
  }

  void _syncWidgetLaunchTarget(List<InspirationItem> items) {
    final requestedItemId = ref.watch(widgetLaunchItemIdProvider);
    if (requestedItemId == null || !_pageController.hasClients) {
      return;
    }

    final targetIndex = items.indexWhere((item) => item.id == requestedItemId);
    if (targetIndex == -1) {
      return;
    }

    if (_currentPage != targetIndex) {
      _currentPage = targetIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) {
          return;
        }

        _pageController.jumpToPage(targetIndex);
      });
    }

    ref.read(widgetLaunchItemIdProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(_provider);

    if (items.isEmpty) {
      _slideshowTimer?.cancel();
      _slideshowTimer = null;
      _currentPage = 0;

      return _EmptyState(providerType: widget.providerType);
    }

    _syncPageIndex(items);
    _syncSlideshow(items);
  _syncWidgetLaunchTarget(items);

    final item = items[_currentPage];
    final cardKey = _cardKeys.putIfAbsent(
      _currentPage,
      () => GlobalKey(),
    );

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!_isSlideshowActive) {
                return;
              }
              setState(() {
                _userInteracted.value = true;
              });
            },
            onPanDown: (_) {
              if (!_isSlideshowActive) {
                return;
              }
              setState(() {
                _userInteracted.value = true;
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) {
                _currentPage = index;
                if (_readAloudEnabled) {
                  unawaited(_speakItem(items[index]));
                }
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final cardKey = _cardKeys.putIfAbsent(
                  index,
                  () => GlobalKey(),
                );
                return Center(
                  child: InspirationCard(
                    item: item,
                    repaintKey: cardKey,
                  ),
                );
              },
            ),
          ),
        ),
        InspirationCardControls(
          isFavorite: item.isFavorite,
          onFavorite: () => _toggleFavorite(item),
          onShare: () async {
            await _shareCard(
              key: cardKey,
              fileName: '${_filePrefixForItem(item)}_${item.id}.png',
            );
          },
          isReadAloudEnabled: _readAloudEnabled,
          isSlideshowPlaying: _isSlideshowActive,
          slideshowPaceLabel: _slideshowPaceLabel,
          onToggleAudio: () async {
            if (_readAloudEnabled) {
              setState(() {
                _readAloudEnabled = false;
              });
              _speechRequestId++;
              _isReadingCurrentItem = false;
              await _ttsService.stop();
              if (_isSlideshowActive) {
                _startSlideshow();
              }
            } else {
              setState(() {
                _readAloudEnabled = true;
              });
              _slideshowTimer?.cancel();
              _slideshowTimer = null;
              unawaited(_speakItem(item));
            }
          },
          onToggleSlideshow: _toggleSlideshow,
          onCycleSlideshowPace: _cycleSlideshowPace,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final InspirationProviderType providerType;

  const _EmptyState({required this.providerType});

  @override
  Widget build(BuildContext context) {
    final isFavorites = providerType == InspirationProviderType.favorites;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.72),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isFavorites ? Icons.bookmarks_outlined : Icons.auto_awesome_outlined,
                size: 48,
                color: AppTheme.primary.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFavorites ? 'No saved favorites yet' : 'Nothing here yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: AppTheme.textPrimary.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isFavorites
                  ? 'Tap the heart on any card and it will appear here for quick access.'
                  : 'Check back soon — more content is on the way.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.75),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyReflectionBanner extends StatelessWidget {
  final InspirationItem item;
  final int streakCount;
  final VoidCallback onTap;

  const _DailyReflectionBanner({
    required this.item,
    required this.streakCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakLabel = streakCount <= 1 ? '${streakCount == 0 ? 1 : streakCount} day streak' : '$streakCount day streak';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.52),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s ${inspirationTypeLabel(item.type)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shortenReflectionText(item.text, maxLength: 92),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        streakLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
