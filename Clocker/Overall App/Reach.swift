// Copyright © 2015 Abhishek Banthia

import Cocoa
import SystemConfiguration

let reachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

enum ReachabilityType: CustomStringConvertible {
    case wwan
    case wiFi

    var description: String {
        switch self {
        case .wwan: return "WWAN"
        case .wiFi: return "WiFi"
        }
    }
}

enum ReachabilityStatus: CustomStringConvertible {
    case offline
    case online(ReachabilityType)
    case unknown

    var description: String {
        switch self {
        case .offline: return "Offline"
        case let .online(type): return "Online (\(type))"
        case .unknown: return "Unknown"
        }
    }
}

open class Reach {
    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }) else {
            return .unknown
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .unknown
        }

        return ReachabilityStatus(reachabilityFlags: flags)
    }

    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!

        SCNetworkReachabilitySetCallback(reachability, { _, flags, _ in
            let status = ReachabilityStatus(reachabilityFlags: flags)

            NotificationCenter.default.post(name: Notification.Name(rawValue: reachabilityStatusChangedNotification),
                                            object: nil,
                                            userInfo: ["Status": status.description])

        }, &context)

        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
}

extension ReachabilityStatus {
    fileprivate init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)

        if !connectionRequired, isReachable {
            self = .online(.wiFi)
        } else {
            self = .offline
        }
    }
}
