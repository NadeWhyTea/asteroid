import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'player.dart';
import 'package:flutter/material.dart';

class AsteroidGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //Load game assets (background, spaceship, asteroids)
    add(SpriteComponent()
        ..sprite = await loadSprite('gameBackground.png')
        ..size = size);

    player = Player();
    add(player);
  }
}