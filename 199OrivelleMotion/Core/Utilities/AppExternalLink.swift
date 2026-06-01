import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://orivelle199motion.site/privacy/227"
        case .termsOfUse:
            return "https://orivelle199motion.site/terms/227"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
