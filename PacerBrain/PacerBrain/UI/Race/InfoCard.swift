//
//  InfoCard.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//
import SwiftUI

struct InfoCard: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Card.cornerRadius).fill(.ultraThinMaterial))
    }
}
