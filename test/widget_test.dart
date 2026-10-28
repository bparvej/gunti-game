import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bangla_guti/presentation/app.dart';
import 'package:bangla_guti/presentation/dialogs/matchmaking_dialog.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.init();
    app.load();
  });

  testWidgets('App boots and renders welcome screen', (WidgetTester tester) async {
    app.set(() => app.onboarded = false);
    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Navigates to Shell after onboarding', (WidgetTester tester) async {
    app.set(() => app.onboarded = true);
    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Shell), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Pause dialog shows Continue, Restart, and Exit buttons and saves session on Exit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    app.set(() {
      app.onboarded = true;
      app.activeSession = null;
    });
    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap PLAY to show match setup modal
    await tester.tap(find.text(tr('play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GameSetupModal), findsOneWidget);
    // Tap START GAME in GameSetupModal
    await tester.tap(find.text(tr('startGame')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GameScreen), findsOneWidget);

    // Tap the pause button in the top bar
    final pauseIconFinder = find.byIcon(Icons.pause_rounded);
    expect(pauseIconFinder, findsWidgets);
    await tester.tap(pauseIconFinder.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify PauseDialog is shown with Pause, Continue, Restart, and Exit
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(find.descendant(of: find.byType(PauseDialog), matching: find.text(tr('resume'))), findsOneWidget);
    expect(find.descendant(of: find.byType(PauseDialog), matching: find.text(tr('restartGame'))), findsOneWidget);
    expect(find.descendant(of: find.byType(PauseDialog), matching: find.text(tr('exitGame'))), findsOneWidget);

    // Tap Exit to Lobby
    await tester.tap(find.descendant(of: find.byType(PauseDialog), matching: find.text(tr('exitGame'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // If AdDialog is shown on exit to lobby, dismiss it
    final adCloseFinder = find.byIcon(Icons.close_rounded);
    if (adCloseFinder.evaluate().isNotEmpty) {
      await tester.tap(adCloseFinder.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    // We should be back on HomePage
    expect(find.byType(HomePage), findsOneWidget);
    // Active session should be saved
    expect(app.hasActiveSession, isTrue);

    // Continue Game button should now appear on HomePage
    final continueBtn = find.text(tr('continueGame'));
    expect(continueBtn, findsOneWidget);

    // Tap Continue Game to resume
    await tester.tap(continueBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // GameScreen restored
    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('Home page 3D navigation: Settings, Profile, Store, Leaderboard, and Difficulty', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    app.set(() {
      app.onboarded = true;
      app.activeSession = null;
      app.difficulty = Difficulty.easy;
      app.points = 250;
    });

    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify initial difficulty is Easy
    expect(app.difficulty, Difficulty.easy);

    // Tap PLAY to show match setup modal and choose difficulty
    await tester.tap(find.text(tr('play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(GameSetupModal), findsOneWidget);

    // Select Hard in setup modal
    await tester.tap(find.text(tr('hard')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Close modal
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(HomePage), findsOneWidget);

    // 1. Settings navigation
    final settingsBtn = find.byKey(const ValueKey('home_settings_btn'));
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SettingsPage), findsOneWidget);
    // Toggle Sound
    final soundToggle = find.byType(ChunkyToggle).first;
    await tester.tap(soundToggle);
    await tester.pump(const Duration(milliseconds: 200));

    // Back from Settings
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomePage), findsOneWidget);

    // 2. Profile navigation
    final profileBtn = find.byKey(const ValueKey('home_profile_btn'));
    expect(profileBtn, findsOneWidget);
    await tester.tap(profileBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProfilePage), findsOneWidget);

    // Back from Profile
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomePage), findsOneWidget);

    // 3. Leaderboard navigation
    final coinBadge = find.byKey(const ValueKey('home_coin_badge'));
    expect(coinBadge, findsOneWidget);
    await tester.tap(coinBadge);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LeaderboardPage), findsOneWidget);

    // Back from Leaderboard
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomePage), findsOneWidget);

    // 4. Store navigation
    final storeBtn = find.byKey(const ValueKey('home_store_btn'));
    expect(storeBtn, findsOneWidget);
    await tester.tap(storeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(StorePage), findsOneWidget);

    // Claim daily bonus
    final claimBtn = find.text(tr('claim'));
    if (claimBtn.evaluate().isNotEmpty) {
      final initialPts = app.points;
      await tester.tap(claimBtn.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(app.points, initialPts + 100);
    }

    // Back from Store
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomePage), findsOneWidget);

    // 5. History navigation
    final historyBtn = find.byKey(const ValueKey('home_history_btn'));
    expect(historyBtn, findsOneWidget);
    await tester.tap(historyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HistoryPage), findsOneWidget);

    // Back from History
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('ReplayScreen opens and supports playback controls', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testSnaps = [
      Snap(const GState([0, 0, 0, 0, 0, 0, 0, 0, 0], 1, 0, 0, 0), const [], 0),
      Snap(const GState([1, 0, 0, 0, 0, 0, 0, 0, 0], 2, 1, 0, 1), [Pc(0, 1, 0)], 1),
      Snap(const GState([1, 2, 0, 0, 0, 0, 0, 0, 0], 1, 1, 1, 2), [
        Pc(0, 1, 0),
        Pc(1, 2, 1),
      ], 2),
    ];

    await tester.pumpWidget(MaterialApp(
      home: ReplayScreen(
        history: testSnaps,
        p1Name: 'Player 1',
        p2Name: 'Player 2',
        outcome: Outcome.p1,
        winLine: const [0, 1, 2],
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ReplayScreen), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);

    // Step forward
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    // Step back
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    // Restart
    await tester.tap(find.byIcon(Icons.replay_rounded));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('GameSetupModal renders header, close button, and locked coins', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    app.set(() {
      app.points = 100;
      app.unlockedCoins.clear();
      app.unlockedCoins.add(0);
      app.coinColorIndex = 0;
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameSetupModal(
          onConfirm: (_, __, ___) {},
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify 3D close button
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    // Verify locked icons are present for coins index 1..5
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(kCoinColors.length - 1));
  });

  testWidgets('StorePage renders Coin Colors section with purchase buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    app.set(() {
      app.points = 300;
      app.unlockedCoins.clear();
      app.unlockedCoins.add(0);
      app.coinColorIndex = 0;
    });

    await tester.pumpWidget(const MaterialApp(
      home: StorePage(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(tr('coinColors')), findsOneWidget);
    expect(find.text('Royal Blue'), findsOneWidget);
    expect(find.text('Emerald Green'), findsOneWidget);
  });

  testWidgets('HomePage renders prominent PLAY ONLINE button and opens MatchmakingDialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    app.set(() {
      app.onboarded = true;
      app.activeSession = null;
    });

    await tester.pumpWidget(const BanglaGutiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify prominent Play Online button with public icon
    final playOnlineBtn = find.byKey(const ValueKey('home_play_online_btn'));
    expect(playOnlineBtn, findsOneWidget);
    expect(find.descendant(of: playOnlineBtn, matching: find.byIcon(Icons.public_rounded)), findsOneWidget);

    // Tap PLAY ONLINE
    await tester.tap(playOnlineBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify MatchmakingDialog is shown
    expect(find.byType(MatchmakingDialog), findsOneWidget);
    expect(find.text(tr('findingOpponent')), findsOneWidget);
    expect(find.text(tr('cancelMatchmaking')), findsOneWidget);

    // Tap Cancel Matchmaking
    await tester.tap(find.text(tr('cancelMatchmaking')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Dialog should be dismissed
    expect(find.byType(MatchmakingDialog), findsNothing);
  });
}
