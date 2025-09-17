//
//  AboutView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftUI


struct AboutView: View {
    let version: String
    let buildNumber: String
    let appIcon: String

    var body: some View {
        VStack(spacing: 10) {
            appTitle
            appIconImage
            appDescription
            versionInformation
            developerInformation
            linksSection
        }
        .padding()
    }

    private var appTitle: some View {
        Text("iSpend")
            .bold()
            .font(.system(size: 18))
    }

    private var appIconImage: some View {
        Group {
            // Use a more modern approach for displaying app icon
            if #available(iOS 15.0, *) {
                // For iOS 15+, use a stylized app representation
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("iSpend")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    )
                    .shadow(radius: 5)
            } else {
                // Fallback for older iOS versions
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                    .overlay(
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("iSpend")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
    }

    private var appDescription: some View {
        Text("Thoughtful spending made easier")
            .italic()
            .font(.system(size: 12))
    }

    private var versionInformation: some View {
        VStack {
            Text("Version \(version)")
                .font(.system(size: 14))
            Text("(build \(buildNumber))")
                .font(.system(size: 12))
        }
    }

    private var developerInformation: some View {
        VStack {
            Text("Designed & Programmed by:")
                .font(.system(size: 12))
            Text("Spencer Marks ⌭ Origami Software")
                .font(.system(size: 12))
        }
    }

    private var linksSection: some View {
        VStack {
            Link("Origami Software", destination: URL(string: "https://origamisoftware.com")!)
            Link("M.I.T. licensed Source Code", destination: URL(string: "https://github.com/smarks/iSpend")!)
            Link("Privacy Policy", destination: URL(string: "https://origamisoftware.com/about/ispend-privacy")!)
            Link("Thanks Paul", destination: URL(string: "https://www.hackingwithswift.com")!)
        }
        .font(.system(size: 12))
    }
}

struct About: Identifiable, Hashable {
    let name: String
    let id: Int
}
