//
//  AuthViewController.swift
//  RESTapiTEST
//
//  Created by Damasya on 2/10/21.
//

import Foundation
import WebKit
protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}
final class AuthViewController:UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let webView = WKWebView()
    private let clientId = "50bcce3ba7154ef9aae80397604bdc10"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        guard let request = request else { return }
        webView.load(request)
        webView.navigationDelegate = self
    }
    private func setupViews(){
        view.backgroundColor = .black
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    private var request: URLRequest?{
        guard var urlComponents = URLComponents(string: "https://oauth.yandex.ru/authorize") else {return nil}
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(clientId)")]
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }
}
//private let scheme = "myphotos" // схема для callback

extension AuthViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "myphotos" {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }

            if let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                print("HI THERE!!")
                delegate?.handleTokenChanged(token: token)
            }
            dismiss(animated: true, completion: nil)
        }
        do {
            decisionHandler(.allow)
        }
    }
}
