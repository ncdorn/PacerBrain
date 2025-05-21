PacerBrain

AI-powered race-day pacing & fueling for endurance athletes

⸻

“Plan hard, race smart.” — The PacerBrain credo

⸻

Table of Contents
	1.	Overview
	2.	Core Features
	3.	Quick Start
	4.	Architecture
	5.	Algorithm Logic
	6.	Roadmap
	7.	Contributing
	8.	License
	9.	Contact

⸻

Overview

PacerBrain is an iOS application that generates personalized pacing and fueling strategies for triathlons, marathons, and other endurance events. Leveraging athlete-specific power curves, course profiles, environmental data, and on-device machine learning, PacerBrain arms athletes with a minute-by-minute plan athletes can trust on race day.

This repository contains the source code, mathematical models, and documentation for the app as it evolves from minimum viable product (MVP) to production launch.

⸻

Core Features
	•	Multi-sport Power Curves — Critical Swim Speed, Critical Power (bike), and Critical Speed (run) models fitted from historical workout data.
	•	Course-Aware Pacing Engine — Optimizes effort against elevation, wind, water conditions, and temperature using nonlinear optimization.
	•	Fueling & Hydration Planner — Predicts carbohydrate & fluid requirements and exports a segment-by-segment nutrition plan.
	•	What-If Simulator — Adjust conditions (temperature, aid-station layout, FTP changes) and instantly see revised pacing.
	•	Race-Day Mode — watchOS companion with time-to-next-split, live nutrition reminders, and audible alerts.
	•	LLM-Powered Coach — Chat interface offering strategy explanations and actionable tips powered by OpenAI.

⸻

Quick Start

Requirements
	•	macOS 15 or later
	•	Xcode 16 (Swift 5.10, SwiftUI 6)
	•	iOS 18 SDK

Installation

# Clone repository
git clone https://github.com/your-org/PacerBrain.git
cd PacerBrain

# Pull submodules (mathematical model library, assets)
git submodule update --init --recursive

Running the App
	1.	Open PacerBrain.xcodeproj in Xcode.
	2.	Select PacerBrain scheme.
	3.	Choose an iPhone 16 Pro simulator or a connected device.
	4.	Build & Run (⌘ R).

Running Tests

swift test --parallel


⸻

Architecture

PacerBrain/
├─ App/                # SwiftUI entry points & navigation
├─ Models/             # Codable & SwiftData models (Athlete, Session, Split)
├─ Algorithms/         # Pacing, nutrition, & weather adjustment engines
├─ Services/           # HealthKit, WeatherKit, CoreLocation wrappers
├─ ViewModels/         # ObservableObjects; combine business logic & UI
├─ Views/              # Reusable SwiftUI views, animations, themes
├─ Resources/          # Assets.xcassets, localized strings, colors
└─ Tests/              # XCTest & snapshot tests

Design Patterns
	•	MVVM + Clean-Swift boundaries
	•	Combine for reactive data flow
	•	Dependency Injection via @Environment(\.dependencies)
	•	Swift Concurrency (async/await) for I/O-bound tasks

⸻

Algorithm Logic

Sport	Primary Model	Key Parameters
Swim	Critical Swim Speed (CSS)	Pool/OW temperature, wetsuit drag, current
Bike	Critical Power (CP) + W′-bal	FTP, W′, aerodynamic drag (CdA), road grade
Run	Critical Speed (CS)	vVO₂max, running economy, air density

An overarching energy-cost integrator couples the three disciplines, honoring glycogen-depletion thresholds and gastrointestinal absorption limits. Weather factors (temperature, humidity, wind) modulate metabolic cost via a Lambda-Q₁₀ scaling factor.

Optimization objective

\min_{P(t)} \int_0^{T} \bigl[ E_c\!\left(P(t), w(t)\right) + \lambda\,\sigma(t) \bigr] \, dt

subject to capacity and comfort constraints (see Docs/Models/Constraints.md).

⸻

Roadmap
	•	MVP sprint (core pacing engine, CSV import, basic UI)
	•	watchOS companion preview
	•	Machine-learning-powered power-curve fitting
	•	Community-shared course database
	•	Multilingual localization

Detailed milestones live in the Project Board.

⸻

Contributing

We welcome issues, feature requests, and pull requests! Please read CONTRIBUTING.md for the branching strategy and code-style guidelines.

Development Scripts

# Format Swift files
mint run swiftformat .

# Lint Markdown docs
markdownlint "**/*.md"


⸻

License

Distributed under the MIT License. See LICENSE for more information.

⸻

Contact

Nicholas Dorn — ndorn@stanford.edu
Cardiovascular Biomechanics Computation Lab

Made with caffeine & Clif Bloks in Palo Alto, CA ☕️🚴‍♂️
