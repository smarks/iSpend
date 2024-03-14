//
//  AboutView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//
// View the About Box

import Foundation
import SwiftUI

struct AboutView: View {
    let version: String
    let buildNumber: String
    let appIcon: String

    var body: some View {
        Text("iSpend").bold().font(.system(size: 18))

        if let image = UIImage(named: appIcon) {
            Image(uiImage: image)
        }

        Text("Thoughtful spending made easier").italic().font(.system(size: 12))
        Spacer()
        Text("Version \(version) ").font(.system(size: 14))
        Text("(build \(buildNumber))").font(.system(size: 12))
        Spacer()
        Text("Designed &  Programmed by:").font(.system(size: 12))
        Text("Spencer Marks ⌭ Origami Software").font(.system(size: 12))
        Spacer()
        let link = "[Origami Software](https://origamisoftware.com)"
        Text(.init(link))
        Spacer()
        let sourceCode = "[M.I.T. licensed Source Code](https://github.com/smarks/iSpend)"
        Text(.init(sourceCode)).font(.system(size: 12))
        Spacer()
        let privacyPolicyLink = "[Privacy Policy](https://origamisoftware.com/about/ispend-privacy)"
        Text(.init(privacyPolicyLink)).font(.system(size: 12))
        Spacer()
        let hackWithSwiftURL = "[Thanks Paul](https://www.hackingwithswift.com)"
        Text(.init(hackWithSwiftURL))
    }
}

struct About: Identifiable, Hashable {
    let name: String
    let id: Int
}
