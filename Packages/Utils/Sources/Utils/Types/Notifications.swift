#if canImport(UserNotifications) && !os(tvOS)

import UserNotifications

/// Helper for Push Notifications.
///
/// Convenience API for checking authorization state, requesting permission,
/// parsing push payload, sending local notifications and more.
///
open class Notifications {

    public let center: UNUserNotificationCenter

    public var isAuthorized: Bool {
        authStatus.isAuthorized
    }

    public var authStatus: UNAuthorizationStatus {
        settings?.authorizationStatus ?? .notDetermined
    }

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        refreshStatus()
    }

    public private(set) var settings: UNNotificationSettings? {
        get {
            guard
                let data = defaults.object(forKey: settingsKey) as? Data,
                let settings = try? NSKeyedUnarchiver.unarchivedObject(
                    ofClass: UNNotificationSettings.self, from: data
                ) else {
                return nil
            }
            return settings
        }
        set {
            if let settings = newValue {
                let data = try? NSKeyedArchiver.archivedData(
                    withRootObject: settings, requiringSecureCoding: true
                )
                defaults.set(data, forKey: settingsKey)
                defaults.synchronize()
            }
        }
    }

    private let settingsKey = "Notifications.Settings"

    private var defaults: UserDefaults {
        .standard
    }

}

public extension Notifications {
    func requestPermission(
        with options: UNAuthorizationOptions = [.sound, .alert, .badge],
        then completion: ((UNAuthorizationStatus) -> Void)? = nil
    ) {
        center.requestAuthorization(options: options) { [weak self] _, _ in
            self?.refreshStatus(then: completion)
        }
    }

    func refreshStatus(then completion: ((UNAuthorizationStatus) -> Void)? = nil) {
        center.getNotificationSettings { [weak self] notificationSettings in
            DispatchQueue.main.async {
                self?.settings = notificationSettings
                completion?(notificationSettings.authorizationStatus)
            }
        }
    }

    func sendLocal(
        content: UNNotificationContent,
        via center: UNUserNotificationCenter = .current(),
        trigger: UNNotificationTrigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3,
            repeats: false
        ),
        then completion: ((Error?) -> Void)? = nil
    ) {
        let request = UNNotificationRequest(
            identifier: content.categoryIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request, withCompletionHandler: completion)
    }

    func tokenString(from data: Data) -> String {
        /// - SEE: http://stackoverflow.com/a/24979958/2165585
        var token: String = ""
        for i in 0..<data.count {
            token += String(format: "%02.2hhx", data[i] as CVarArg)
        }
        return token
    }
}

extension Notifications {

    public struct Payload {
        public let userInfo: [AnyHashable: Any]

        public let aps: APS

        public var content = UNMutableNotificationContent()

        public struct APS {
            public struct Alert {
                public let title: String?
                public let subtitle: String?
                public let body: String?
            }

            public let alert: Alert?
            public let badge: Int?
            public let sound: String?

            public let category: String?
            public let thread: String?
            public let targetContent: String?

            public let contentAvailable: Int?
            public let mutableContent: Int?

            public init(userInfo: [AnyHashable: Any]) {
                let aps = userInfo["aps"] as? [AnyHashable: Any]

                let alertData = aps?["alert"] as? [AnyHashable: Any]
                alert = Alert(
                    title: alertData?["title"] as? String,
                    subtitle: alertData?["subtitle"] as? String,
                    body: alertData?["body"] as? String
                )
                badge = aps?["badge"] as? Int
                sound = aps?["sound"] as? String

                category = aps?["category"] as? String
                thread = aps?["thread-id"] as? String
                targetContent = aps?["target-content-id"] as? String

                contentAvailable = aps?["content-available"] as? Int
                mutableContent = aps?["mutable-content"] as? Int
            }
        }

        public init(userInfo: [AnyHashable: Any]) {
            self.userInfo = userInfo
            aps = APS(userInfo: userInfo)

            updateContent()
        }

        private func updateContent() {
            content.userInfo = userInfo

            if let title = aps.alert?.title {
                content.title = title
            }
            if let subtitle = aps.alert?.subtitle {
                content.subtitle = subtitle
            }
            if let body = aps.alert?.body {
                content.body = body
            }

            if let badge = aps.badge {
                content.badge = NSNumber(value: badge)
            }
            if let sound = aps.sound {
                #if os(watchOS)
                content.sound = .default
                #else
                content.sound = UNNotificationSound(
                    named: UNNotificationSoundName(rawValue: sound)
                )
                #endif
            }

            if let category = aps.category {
                content.categoryIdentifier = category
            }
            if let thread = aps.thread {
                content.threadIdentifier = thread
            }
            if let targetContent = aps.targetContent {
                content.targetContentIdentifier = targetContent
            }
        }
    }

}

public extension Notifications.Payload {
    init(_ notification: UNNotification) {
        self.init(userInfo: notification.request.content.userInfo)
    }

    init?(apnsFile name: String) {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "apns"),
            let data = try? Data(contentsOf: url, options: .mappedIfSafe),
            let json = try? JSONSerialization
            .jsonObject(with: data, options: .mutableContainers),
            let userInfo = json as? [AnyHashable: Any]
        else {
            return nil
        }
        self = Self(userInfo: userInfo)
    }
}

public extension UNAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }
}

#endif
