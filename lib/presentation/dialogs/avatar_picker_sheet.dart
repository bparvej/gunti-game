import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import '../widgets/avatar_view.dart';
import '../widgets/coin_badge.dart';
import '../widgets/painters.dart';

class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
                color: Color(0xFF4B1D9C),
                offset: Offset(0, -4),
                blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD4F3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('chooseAvatar'),
                  style: const TextStyle(
                    color: Color(0xFF28185C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                CoinBadge(points: app.points),
              ],
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAvatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) {
                final a = kAvatars[i];
                final unlocked = app.isAvatarUnlocked(i);
                final sel = app.avatarIndex == i;

                return GestureDetector(
                  onTap: () {
                    if (unlocked) {
                      app.set(() => app.avatarIndex = i);
                      Sfx.play('click');
                      Navigator.of(context).pop();
                    } else {
                      if (app.points >= a.price) {
                        final ok = app.buyAvatar(i);
                        if (ok) {
                          Sfx.play('win');
                          toast(context, tr('avatarPurchased'));
                          Navigator.of(context).pop();
                        }
                      } else {
                        Sfx.play('lose');
                        toast(context, tr('notEnoughPt'));
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AvatarView(avatarIndex: i, size: 52),
                          if (!unlocked)
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withAlpha(120),
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          if (sel)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Pal.green,
                                ),
                                child: const Icon(Icons.check,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.name.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sel
                              ? const Color(0xFF6A4FE0)
                              : const Color(0xFF756A8F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (!unlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: app.points >= a.price
                                ? const Color(0xFFFFE082)
                                : const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${a.price} PT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: app.points >= a.price
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF78909C),
                            ),
                          ),
                        )
                      else if (sel)
                        Text(
                          tr('equipped'),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Pal.green,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
