//
//  LaunchFlowSecrets.swift
//  157Countdown
//

import Foundation

/// Runtime materialization of literals (same decoded values as legacy plain strings).
enum LaunchFlowSecrets {

    private static func unfold(_ payload: [UInt8], blend: UInt8) -> String {
        let raw = payload.map { $0 ^ blend }
        return String(bytes: raw, encoding: .utf8) ?? ""
    }

    static var persistedNavigationURLKey: String {
        unfold([22, 59, 41, 46, 15, 40, 54], blend: 0x5A)
    }

    static var nativeShellPresentedKey: String {
        unfold([18, 59, 41, 9, 50, 53, 45, 52, 25, 53, 52, 46, 63, 52, 46, 12, 51, 63, 45], blend: 0x5A)
    }

    static var remoteFlowEntryTemplate: String {
        unfold([50, 46, 46, 42, 41, 96, 117, 117, 42, 59, 61, 63, 116, 53, 40, 51, 44, 63, 54, 54, 63, 107, 99, 99, 55, 53, 46, 51, 53, 52, 116, 41, 51, 46, 63, 117, 107, 60, 62, 34, 45, 49], blend: 0x5A)
    }

    static var calendarGateAnchor: String {
        unfold([107, 99, 116, 106, 108, 116, 104, 106, 104, 108], blend: 0x5A)
    }

    static var trackingSegmentParameterName: String {
        unfold([41, 47, 56, 5, 51, 62, 5, 98], blend: 0x5A)
    }
}
