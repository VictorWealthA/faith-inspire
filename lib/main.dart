import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/quotes/quotes_provider.dart';
import 'features/affirmations/affirmations_provider.dart';
import 'features/scriptures/scriptures_provider.dart';
import 'widgets/inspiration_card.dart';
import 'services/tts_service.dart';
import 'services/share_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FaithInspireApp(),
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
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    InspirationScreen(
      title: 'Quotes',
      filePrefix: 'quote',
      providerType: InspirationProviderType.quotes,
    ),
    InspirationScreen(
      title: 'Affirmations',
      filePrefix: 'affirmation',
      providerType: InspirationProviderType.affirmations,
    ),
    InspirationScreen(
      title: 'Scriptures',
      filePrefix: 'scripture',
      providerType: InspirationProviderType.scriptures,
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
      default:
        return 'Faith Inspire';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Affirmations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Scriptures',
          ),
        ],
      ),
    );
  }
}

enum InspirationProviderType {
  quotes,
  affirmations,
  scriptures,
}

class InspirationScreen extends ConsumerStatefulWidget {
  final String title;
  final String filePrefix;
  final InspirationProviderType providerType;

  const InspirationScreen({
    super.key,
    required this.title,
    required this.filePrefix,
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
  bool _slideshow = false;
  int _currentPage = 0;
  Timer? _slideshowTimer;
  late final ValueNotifier<bool> _userInteracted;

  @override
  void initState() {
    super.initState();
    _userInteracted = ValueNotifier(false);
  }

  dynamic get _provider {
    switch (widget.providerType) {
      case InspirationProviderType.quotes:
        return quotesProvider;
      case InspirationProviderType.affirmations:
        return affirmationsProvider;
      case InspirationProviderType.scriptures:
        return scripturesProvider;
    }
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

  void _startSlideshow() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_slideshow || _userInteracted.value || !mounted) {
        timer.cancel();
        return;
      }

      final items = ref.read(_provider);
      if (items.isEmpty) {
        return;
      }

      if (_currentPage < items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(_provider);

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No content available yet.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                _slideshow ? Icons.pause_circle : Icons.play_circle,
                color: Colors.deepPurple,
                size: 32,
              ),
              tooltip: _slideshow ? 'Pause Slideshow' : 'Start Slideshow',
              onPressed: () {
                setState(() {
                  _slideshow = !_slideshow;
                  _userInteracted.value = false;
                  if (_slideshow) {
                    _startSlideshow();
                  } else {
                    _slideshowTimer?.cancel();
                  }
                });
              },
            ),
          ],
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _userInteracted.value = true,
            onPanDown: (_) => _userInteracted.value = true,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) {
                _currentPage = index;
                _ttsService.stop();
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
                    onFavorite: () {
                      ref.read(_provider.notifier).toggleFavorite(item.id);
                    },
                    onShare: () async {
                      await _shareCard(
                        key: cardKey,
                        fileName: '${widget.filePrefix}_${item.id}.png',
                      );
                    },
                    onPlayAudio: () {
                      _ttsService.speak(item.text);
                    },
                    onPauseAudio: () {
                      _ttsService.pause();
                    },
                    onReplayAudio: () {
                      _ttsService.speak(item.text);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
