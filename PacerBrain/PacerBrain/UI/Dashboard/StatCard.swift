//
//  StatCard.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//
import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .oversizedIconSize(.small)
                .foregroundColor(.accentColor)
                .padding(.horizontal)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3.bold())
            }
            

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius, style: .continuous))
        .subtleShadow()
    }
}
