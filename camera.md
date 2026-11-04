# FlickSix — Camera Systems Design

**Status:** Deferred for Post-Gameplay Polish  
**Feature:** Multi-Perspective Camera Array (with First-Person Batting)

---

## 1. Overview
FlickSix will feature three distinct camera perspectives switchable in real-time via the Pause Menu / Settings (and hotkey `C` in debug mode). This provides player personalization and establishes FlickSix as a pioneer in offering a true FPS cricket batting perspective.

---

## 2. The Three Camera Presets

### Preset 1: Broadcast (High-Behind)
* **Coordinates:** Centered behind stumps at `Vector3(0.0, 2.1, 3.4)` looking down the pitch over the bails.
* **Feel:** Traditional TV broadcast / arcade perspective. Wide situational awareness of the pitch and field.

### Preset 2: Over-The-Shoulder (Action Sports)
* **Coordinates:** Offset to off-side / right-hand striker at `Vector3(0.55, 1.85, 2.4)`.
* **Feel:** Modern 3rd-person sports action (*Real Cricket / WCC* style). Frames the batsman model and bat blade close to the screen edge.

### Preset 3: First-Person Striker (FPS Cam — Unique Selling Point)
* **Coordinates:** Centered at striker eye-level at `Vector3(0.2, 1.65, 0.2)` looking directly down the pitch towards the bowler.
* **Feel:** Pure arcade intensity and immersion. The player sees deliveries hurtling straight towards their face, with the bat held in the peripheral view.

---

## 3. Implementation Blueprint
* Camera preset enum: `enum CameraMode { BROADCAST, OVER_SHOULDER, FPS }`.
* Stored in player preferences config.
* Smooth camera transition tween when toggled in pause menu.

