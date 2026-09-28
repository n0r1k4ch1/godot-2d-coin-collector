#  Coin Collector 2D - Godot Engine Mini-Game

> A polished, arcade-style 2D coin-collector mini-game built with **Godot Engine 4 (Compatibility Mode)** and **GDScript**. Designed with a strong focus on game feel, responsive controls, and procedural game elements.

---

##  Gameplay & Mechanics

- **Fluid Movement:** Character controller featuring custom acceleration (2600.0), deceleration friction (2200.0), dynamic directional tilt, and sprite horizontal flipping.
- **Arena Screen Clamping:** Prevents the player from moving beyond viewport boundaries.
- **Smart Coin Spawner:** 
  - Dynamic procedural positioning ensuring newly spawned coins maintain a minimum distance (>= 140px) from the player.
  - Spawn capacity cap (`MAX_COINS = 5`) with adaptive replenishment when the arena is cleared.
- **Animation & "Juice" (Tweens):**
  - Smooth scale pop-in on coin spawn.
  - Continuous floating/bobbing sine-wave motion per coin.
  - Pickup sequence: Scale pulse, upward floating fade-out, and instantaneous collision disabling to prevent duplicate trigger bugs.
- **Procedural 8-Bit Audio:** Retro arcade collection sound generated dynamically in runtime GDScript using `AudioStreamWAV` without external audio assets.
- **Dynamic HUD:**
  - Modern anchored UI displaying collected coins and movement instructions.
  - "+1" floating text animation at the exact collection coordinates.
  - Punch-scale bounce effect on score increments.

---

##  Tech Stack & Architecture

- **Engine:** Godot Engine 4.x
- **Renderer:** Compatibility (OpenGL 3 / WebGL)
- **Language:** GDScript
- **Key Nodes & Systems:** `CharacterBody2D`, `Area2D`, `CanvasLayer`, `Tween`, `AudioStreamWAV`

---

##  Project Structure

```text
mini-game-2d/
├── character_body_2d.gd   # Player controller (movement, physics, tilt, boundary clamp)
├── coin.gd                # Coin behavior (signals, collection tween, floating logic)
├── coin.svg               # Custom vector coin asset
├── coin.tscn              # Coin scene (Area2D + CircleShape2D)
├── node_2d.gd             # Game manager (scoring, procedural audio, spawning logic)
├── node_2d.tscn           # Main arena scene & HUD
├── project.godot          # Engine configuration file
└── .gitignore             # Git exclusion rules

Getting Started
Prerequisites
Godot Engine 4.x (Standard Version)

Running Locally
Clone the repository:

Bash
git clone [https://github.com/n0r1k4ch1/godot-2d-coin-collector.git](https://github.com/n0r1k4ch1/godot-2d-coin-collector.git)
Launch Godot Engine.

Click Import, browse to the cloned directory, and select project.godot.

Press F5 to run the project.

Controls
W / Up Arrow: Move Up

S / Down Arrow: Move Down

A / Left Arrow: Move Left

D / Right Arrow: Move Right