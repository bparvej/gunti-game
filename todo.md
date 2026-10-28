# Bangla Guti - Development Task Checklist

## All Tasks Completed & Verified

### A. Non-FVM & Toolchain Compatibility
- [x] **Run Project without FVM**: Configured `pubspec.yaml` environment to `sdk: '>=3.7.0 <4.0.0'` and updated `flutter_lints` (^5.0.0) and `vibration` (^3.1.8) to run natively with system Flutter (Flutter 3.29.1, Dart 3.7.0).
- [x] **Gradle 8.13 & AGP 8.13.2**: Android project builds cleanly with Gradle 8.13 and Android Gradle Plugin 8.13.2 on JDK 21 without modifying Flutter or Dart SDK versions.
- [x] **Analyze & Tests Passing**: `flutter analyze` 0 issues; all 48 tests pass cleanly.

### B. Coin Selection Gating & Store Economy
- [x] **Limit Coin Selection to Purchased Coins**:
  - Tapping a locked coin in `GameSetupModal` does not allow selecting/equipping it.
  - Locked coins display a lock icon (`Icons.lock_rounded`) and PT price tag.
  - Tapping locked coins prompts immediate purchase if player has sufficient PT balance.
- [x] **Coin Pricing & Persistence**:
  - Index 0 (Purple): 0 PT (Free)
  - Index 1 (Royal Blue): 150 PT
  - Index 2 (Emerald Green): 250 PT
  - Index 3 (Sunset Gold): 350 PT
  - Index 4 (Ruby Red): 500 PT
  - Index 5 (Teal Cyan): 600 PT
  - Stored in `AppState.unlockedCoins`, persisted to JSON, fallbacks to 0 if locked.
- [x] **Store Page Coins Section**:
  - Added dedicated "Coin Colors" / "গুটির রঙ" section in `StorePage`.
  - Preview piece (`Guti`), price tag, and 3D ChunkyButton ("Equipped", "Equip", or "Buy X PT") with live balance deduction.

### C. Displaced Cross / Close Button Fix
- [x] **Fixed Dialog Header Layout**: Header `SizedBox` updated to `width: double.infinity` across `GameSetupModal` and `MatchmakingDialog`.
- [x] **Anchored Top-Right 3D Close Button**: Replaced displaced button with QuizOn 3D `ChunkyIconButton(icon: Icons.close_rounded, size: 34)` anchored at `Positioned(right: 12, top: 10)` so it sits cleanly in the modal's top-right corner.

### D. Play Online Mode (Simulated Realistic Opponent)
- [x] **Mode.online**: Integrated into game state, controller, history, and results.
- [x] **Realistic Opponents**: Pool of realistic names (`Rahim_BD`, `Tanvir_Pro`, `Shakib99`, `Anik_Guti`, `Tariqul_7`, `Priya_Queen`, `Sumon_Champa`, `Niloy_Rider`, etc.) with random avatars, simulated ping (e.g. `36 ms`), and ratings.
- [x] **Human-like Turn Delays**: Opponent takes a random thinking turn between 2.0s and 7.5s (strictly within 10s) using device AI in the background, with "Opponent is thinking..." status indicator.
- [x] **Matchmaking Dialog**: 3D QuizOn modal with radar pulse search animation, search duration timer, player rating, latency badge, and transition to match found.
- [x] **Prominent Home Page Button**: High-visibility 3D QuizOn "PLAY ONLINE" `ChunkyButton` on Home Page.
- [x] **Localization**: Bilingual support (English & Bengali) for all online matchmaking and game strings.

### E. Performance & Battery Drain Elimination
- [x] **Isolated Repaint Boundaries**: Added `RepaintBoundary` around `HomeHero`, board grid lines (`LinesPainter`), animated pieces, and tutorial pointer.
- [x] **Background / Inactive Ticker Pausing**: Hero star bobbing animation ticker (`_starCtrl`) pauses automatically whenever the app is backgrounded or when navigating away from Home.
- [x] **Raster & Painter Caching**: Configured `isComplex: true` and `willChange: false` on static painters (`LinesPainter`, `RibbonPainter`). Pre-allocated static `Paint` instances and pre-calculated `Color.lerp` in `GutiPainter`.
- [x] **Throttled Timer Rebuilds**: Suppressed redundant widget rebuilds during idle/countdown ticks when visual state does not change.

### F. Core Game Rules & Polish
- [x] Pre-placed coins at start: P1 at [6, 7, 8], P2 at [0, 1, 2], middle [3, 4, 5] empty.
- [x] Non-win starting lines rule: P1 cannot win on [6, 7, 8]; P2 cannot win on [0, 1, 2].
- [x] First-time tutorial indicator and hint pointer.
- [x] In-game 3D hint button (1st free, subsequent via simulated rewarded Ad).
- [x] Interstitial Ad on quitting match to lobby.
- [x] Unified 3D `ChunkyButton` and `LevelBar` everywhere.
- [x] 5-second countdown with cancel button before auto-mode triggers.
- [x] Avatar store with PT deduction.
