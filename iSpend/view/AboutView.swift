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
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                appTitle
                appIconImage
                appDescription
                versionInformation
                developerInformation
                linksSection
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var appTitle: some View {
        Text("iSpend")
            .bold()
            .font(.system(size: 18))
    }

    private var appIconImage: some View {
        // Correctly handle the optional UIImage and ensure a view is always returned
        Group {
            if let image = UIImage(named: appIcon) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            } else {
                // Provide a fallback view in case the image is not found
                Image(systemName: "app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
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
