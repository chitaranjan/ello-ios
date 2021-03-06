////
///  ElloWebViewHelper.swift
//

struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"

    @discardableResult
    static func handle(request: URLRequest, origin: UIResponder?, fromWebView: Bool = false) -> Bool {
        guard let requestUrlString = request.url?.absoluteString
        else { return true }

        if requestUrlString.hasPrefix(ElloWebViewHelper.jsCommandProtocol) {
            return false
        }
        else if requestUrlString.range(of: "(https?:\\/\\/|mailto:)", options: String.CompareOptions.regularExpression) != nil {
            let (type, data) = ElloURI.match(requestUrlString)
            if type == .email {
                if let url = URL(string: requestUrlString) {
                    UIApplication.shared.openURL(url)
                }
                return false
            }
            else {
                if fromWebView && type.loadsInWebViewFromWebView { return true }
                let responder = origin?.target(forAction: #selector(WebLinkResponder.webLinkTapped(path:type:data:)), withSender: origin) as? WebLinkResponder
                responder?.webLinkTapped(path: requestUrlString, type: ElloURIWrapper(uri: type), data: data)
                return false
            }
        }
        return true
    }

    static func bypassInAppBrowser(_ url: URL?) -> Bool {
        guard let urlString = url?.absoluteString else { return false }

        if urlString =~ "(https?:\\/\\/appstore.com)" { return true }
        if urlString =~ "(https?:\\/\\/itunes.apple.com)" { return true }

        return false
    }
}
