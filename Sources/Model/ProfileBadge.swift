////
///  ProfileBadge.swift
//

enum ProfileBadge: String {
    case featured
    case community
    case experimental
    case staff
    case spam
    case nsfw

    var name: String {
        switch self {
        case .featured:
            return InterfaceString.Badges.Featured
        case .community:
            return InterfaceString.Badges.Community
        case .experimental:
            return InterfaceString.Badges.Experimental
        case .staff:
            return InterfaceString.Badges.Staff
        case .spam:
            return InterfaceString.Badges.Spam
        case .nsfw:
            return InterfaceString.Badges.Nsfw
        }
    }

    var link: String {
        switch self {
        case .staff:
            return InterfaceString.Badges.StaffLink
        default:
            return InterfaceString.Badges.LearnMore
        }
    }

    var url: URL? {
        switch self {
        case .staff:
            return URL(string: "https://ello.co/wtf/about/team/")
        case .spam, .nsfw:
            return nil
        default:
            return URL(string: "https://ello.co/wtf/help/badges/")
        }
    }

    var image: InterfaceImage {
        switch self {
        case .featured:
            return .badgeFeatured
        case .community:
            return .badgeCommunity
        case .experimental:
            return .badgeExperimental
        case .staff:
            return .badgeStaff
        case .spam:
            return .badgeSpam
        case .nsfw:
            return .badgeNsfw
        }
    }
}
