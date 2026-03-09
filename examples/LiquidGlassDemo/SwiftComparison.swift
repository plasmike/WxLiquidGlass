import SwiftUI
import AppKit

@main
struct TransparentWindowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.clear)
                .onAppear {
                    makeWindowTransparent()
                }
        }
    }

    func makeWindowTransparent() {
        if let window = NSApplication.shared.windows.first {
            window.title = "Liquid Glass using SwiftUI and AppKit"
            window.isOpaque = false
            window.backgroundColor = .clear
            window.styleMask.insert(.titled)
        }
    }
}

struct ContentView: View {
    var body: some View {
          // Liquid glass rectangle
          RoundedRectangle(cornerRadius: 16)
              .glassEffect(.regular, in: .rect(cornerRadius: 16)) // either .regular or .clear
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
}

// compile using this command: "swiftc SwiftComparison.swift -parse-as-library"
// doesnt work for me if I remove -parse-as-library
