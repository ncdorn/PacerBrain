## 🧠 Performance Models

PacerBrain fits smooth, discipline-specific models to each athlete’s performance data to generate realistic pacing targets for any race duration. These models are derived from endurance science literature and fitted automatically using your training history.

### 🏊 Swim – Stroke-Rate Decay Model

Uses critical swim speed (CSS) and an exponential fatigue decay:

```
v(t) = CSS - δ · (1 - e^(–k · t))
```

- `CSS`: estimated from 200/400 m swim tests
- `δ`: max velocity drop from stroke fatigue
- `k`: decay constant (≈ 0.002–0.006 s⁻¹)

### 🚴‍♂️ Bike – 3-Parameter Critical Power Model

Models power over time using both aerobic (CP) and anaerobic (W′) components:

```
P(t) = CP + W′ / (t + k)
```

- `CP`: critical power — max steady-state output
- `W′`: anaerobic work capacity (joules)
- `k`: curvature constant — shapes mid-duration decay

### 🏃‍♂️ Run – Power-Law Endurance Model

Predicts sustainable running velocity over time with a power law:

```
v(t) = S · t^(–E)
```

- `S`: intercept (speed at 1 second)
- `E`: endurance exponent (0.05–0.09 typical)

### 🔁 Model Fitting

Each curve is built from your recorded duration–output points (e.g. from workouts or races) using:

- Log-linear regression (for the run power law)
- Grid search (for CP and swim models)
- Extensible protocols for future models (e.g. temperature, fatigue)
