# FlickSix — Bowling Specs & Pace Profiles

**Status:** Reference Specification for AI & Bowler Delivery Variations

---

## 1. Flight Times & Pace Hierarchy

* **Fast Bowler (Express Pace / ~145 km/h):**
  * `flight_time = 0.50s`
  * Aggressive speed, compressed reaction window.
* **Medium Pacer (~120 km/h):**
  * `flight_time = 0.60s` (Current prototype default)
  * Balanced pace, standard timing window.
* **Spin Bowler (~85 km/h):**
  * `flight_time = 0.90s`
  * Slower loop through the air, giving batsman time to advance or read drift, followed by sharp post-bounce turn.

---

## 2. Planned Spin Mechanics
* Pre-bounce air drift along X-axis.
* Post-bounce seam/spin angle deviation (off-spin turning into batsman, leg-spin turning away).

