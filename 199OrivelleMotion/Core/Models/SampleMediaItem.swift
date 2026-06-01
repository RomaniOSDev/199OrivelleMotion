import SwiftUI

struct SampleMediaItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let accentHue: Double

    static let curated: [SampleMediaItem] = [
        SampleMediaItem(
            id: "sunset-vibes",
            title: "Sunset Vibes",
            description: "Warm golden hour tones and peaceful horizons.",
            iconName: "sun.max.fill",
            accentHue: 0.08
        ),
        SampleMediaItem(
            id: "urban-stories",
            title: "Urban Stories",
            description: "Cityscapes and street life captured in detail.",
            iconName: "building.2.fill",
            accentHue: 0.55
        ),
        SampleMediaItem(
            id: "nature-trails",
            title: "Nature Trails",
            description: "Forests, mountains, and open landscapes.",
            iconName: "leaf.fill",
            accentHue: 0.35
        ),
        SampleMediaItem(
            id: "coastal-moments",
            title: "Coastal Moments",
            description: "Ocean waves, beaches, and seaside calm.",
            iconName: "water.waves",
            accentHue: 0.58
        ),
        SampleMediaItem(
            id: "family-gatherings",
            title: "Family Gatherings",
            description: "Celebrations and shared moments with loved ones.",
            iconName: "person.3.fill",
            accentHue: 0.95
        ),
        SampleMediaItem(
            id: "creative-shots",
            title: "Creative Shots",
            description: "Artistic angles and experimental compositions.",
            iconName: "camera.aperture",
            accentHue: 0.75
        ),
        SampleMediaItem(
            id: "travel-diaries",
            title: "Travel Diaries",
            description: "Adventures from places near and far.",
            iconName: "airplane",
            accentHue: 0.62
        ),
        SampleMediaItem(
            id: "quiet-reflections",
            title: "Quiet Reflections",
            description: "Still life and contemplative scenes.",
            iconName: "moon.stars.fill",
            accentHue: 0.72
        )
    ]
}
