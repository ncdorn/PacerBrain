# 🧠 PacerBrain

**PacerBrain** is an iOS app that generates personalized race-day pacing and fueling strategies for endurance athletes. By modeling physiology, energy cost, and course terrain, PacerBrain helps athletes plan smarter, perform stronger, and finish faster.

---

## 🚀 Features

- 📈 **Pacing Strategy Engine**  
  Calculates optimal split pacing based on critical power/speed models and course profiles.

- 🔋 **Fueling Plan Generator**  
  Estimates carbohydrate needs, ingestion timing, and adjusts for heat and GI tolerance.

- 📊 **Effort Modeling by Discipline**  
  - Swim: Critical Swim Speed (CSS)  
  - Bike: Critical Power (CP) and W′ balance  
  - Run: Critical Speed (CS) and D′ distance capacity

- 🌡️ **Weather-Aware Performance Adjustment**  
  Automatically adjusts effort and fuel planning for heat, humidity, and wind.

- 🧪 **Custom Athlete Profiles**  
  Import or define key fitness metrics (FTP, CSS, sweat rate, CHO tolerance).

- 📍 **Course Segmentation**  
  Supports manual or GPX-based course input, with segment-by-segment pacing output.

---

## 📱 Screenshots

*(Coming soon: annotated SwiftUI previews of each screen)*

---

## 🛠️ Tech Stack

- **SwiftUI** – Modern declarative UI for iOS
- **SwiftData / CoreData** – Athlete & course persistence
- **HealthKit (planned)** – Integration with health and training data
- **MapKit / GPX Parser (planned)** – Course mapping and segmentation
- **Numerical Optimization** – Per-segment pacing solver with effort and energy constraints

---

## 🧮 Mathematical Models

PacerBrain uses physiologically grounded models:

| Discipline | Model | Key Variables |
|------------|--------|----------------|
| Swim | Critical Swim Speed (CSS) | \( v = \text{CSS} + \frac{W'}{t} \) |
| Bike | Critical Power (CP), W′ | \( W_{\text{bal}}(t+\Delta t) = W_{\text{bal}}(t) + \ldots \) |
| Run | Critical Speed (CS), D′ | \( v = v_{\text{CS}} + \frac{D'}{t} \) |
| Fueling | CHO Balance | \( \sum \text{CHO} \leq \text{Stored} + \text{Ingested} \) |

For full details, see [`docs/mathematical_models.tex`](docs/mathematical_models.tex).

---

## 🔧 Setup & Development

1. Clone the repo:
    ```bash
    git clone https://github.com/your-username/pacerbrain.git
    cd pacerbrain
    ```

2. Open the project in Xcode:
    ```bash
    open PacerBrain.xcodeproj
    ```

3. Build and run on a simulator or real device.

> Requires Xcode 15+, iOS 17 SDK.

---

## 🧪 Testing

PacerBrain includes unit tests for core physiological and optimization logic:

```bash
⌘U in Xcode
