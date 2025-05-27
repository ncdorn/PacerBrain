## \ud83e\udde0 Performance Models

PacerBrain fits smooth, discipline-specific models to each athlete\u2019s performance data to generate realistic pacing targets for any race duration. These models are derived from endurance science literature and fitted automatically using your training history.

### \ud83c\udfca Swim \u2013 Stroke-Rate Decay Model

Uses critical swim speed (CSS) and an exponential fatigue decay:

```
v(t) = CSS - \u03b4 \xb7 (1 - e^(\u2013k \xb7 t))
```

- `CSS`: estimated from 200/400 m swim tests
- `\u03b4`: max velocity drop from stroke fatigue
- `k`: decay constant (\u2248 0.002\u20130.006 s\u207b\u00b9)

### \ud83d\udeb4\ufe0f Bike \u2013 3-Parameter Critical Power Model

Models power over time using both aerobic (CP) and anaerobic (W\u2032) components:

```
P(t) = CP + W\u2032 / (t + k)
```

- `CP`: critical power \u2014 max steady-state output
- `W\u2032`: anaerobic work capacity (joules)
- `k`: curvature constant \u2014 shapes mid-duration decay

### \ud83c\udfc3\u200d\u2642\ufe0f Run \u2013 Power-Law Endurance Model

Predicts sustainable running velocity over time with a power law:

```
v(t) = S \xb7 t^(\u2013E)
```

- `S`: intercept (speed at 1 second)
- `E`: endurance exponent (0.05\u20130.09 typical)

### \ud83d\udd01 Model Fitting

Each curve is built from your recorded duration\u2013output points (e.g. from workouts or races) using:

- Log-linear regression (for the run power law)
- Grid search (for CP and swim models)
- Extensible protocols for future models (e.g. temperature, fatigue)

