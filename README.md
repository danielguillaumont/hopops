# HopOps

**You are the packet. The city is your network.**

What if planning a road trip felt a little like running a traceroute?

HopOps is a playful iOS route planner that turns real-world destinations into network hops. Pick two relay stops, choose your final endpoint, and trace your journey across an interactive map.

## Features

- **Live GPS origin** — Start from your current location.
- **Three destinations** — Search for two relay stops and a final endpoint.
- **Visual routing** — Display colour-coded driving routes across the map.
- **Route log** — Browse turn-by-turn directions for the full journey or individual hops.
- **Map controls** — Re-centre your journey whenever you wander off course.
- **Error handling** — Handle invalid addresses and unavailable routes gracefully.

## Built With

- Swift
- SwiftUI
- MapKit
- Core Location

## Getting Started

1. Clone this repository.
2. Open `HopOps.xcodeproj` in Xcode.
3. Select an iPhone simulator or device running iOS 17 or later.
4. Build and run the app.
5. Tap **LOCATE ME** to establish your starting point.
6. Enter two stops and a final destination.
7. Tap **DROP PINS**, then **TRACE ROUTE**.

For simulator testing, you can configure a simulated GPS location.

## The Idea

In computer networking, packets travel between nodes to reach their destination.

HopOps borrows that concept for real-world journeys. Your phone is the starting node, your stops are relay nodes, and your destination is the final endpoint.

No actual packet sniffing or network tracing here — just maps, routes, and a little networking personality.

---

*Built for the fun of making things.*
