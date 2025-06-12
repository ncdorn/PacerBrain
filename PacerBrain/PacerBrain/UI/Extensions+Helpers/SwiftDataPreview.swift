//
//  SwiftDataPreview.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/1/25.
//

import SwiftUI
import SwiftData

struct SwiftDataPreview: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: Race.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        // maybe load up some sample data into container.mainContext
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait<Preview.ViewTraits> {
    @MainActor static var swiftData: Self = .modifier(SwiftDataPreview())
}
