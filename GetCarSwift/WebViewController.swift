//
//  WebViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/16.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView = WKWebView()
    var progressView: UIProgressView!
    var backBarButton: UIBarButtonItem!
    var forwardBarButton: UIBarButtonItem!
    var refreshBarButton: UIBarButtonItem!
    var stopBarButton: UIBarButtonItem!
    var flexibleSpaceBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black()
        webView.navigationDelegate = self
        webView.isMultipleTouchEnabled = true
        webView.scrollView.alwaysBounceVertical = true
        webView.backgroundColor = UIColor.black()
        webView.scrollView.backgroundColor = UIColor.black()
        self.view.addSubview(webView)

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.progressView.frame.size.height)
        progressView.trackTintColor = UIColor(white: 1, alpha: 0)
        self.view.addSubview(progressView)

        backBarButton = UIBarButtonItem(image: R.image.backbutton, style: .plain, target: self, action: #selector(WebViewController.didBack))
        forwardBarButton = UIBarButtonItem(image: R.image.forwardbutton, style: .plain, target: self, action: #selector(WebViewController.didForward))
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(WebViewController.didRefresh))
        stopBarButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(WebViewController.didStop))
        flexibleSpaceBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        backBarButton.width = 44
        forwardBarButton.width = 44

        updateToolBar()
    }

    override func viewDidLayoutSubviews() {
        webView.frame = self.view.frame
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true
    }

    func updateToolBar() {
        backBarButton.isEnabled = webView.canGoBack
        forwardBarButton.isEnabled = webView.canGoForward
        self.toolbarItems = [backBarButton, forwardBarButton, flexibleSpaceBarButton, webView.isLoading ? stopBarButton : refreshBarButton]
        self.navigationItem.title = webView.title
    }

    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func loadURLString(_ urlString: String) {
        loadURL(URL(string: urlString)!)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1
            let animated = webView.estimatedProgress > Double(progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated:animated)

            // Once complete, fade out UIProgressView
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.progressView.alpha = 0.0
                    }, completion: { (_) in
                        self.progressView.setProgress(0.0, animated:false)
                })
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolBar()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateToolBar()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: NSError) {
        updateToolBar()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolBar()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            loadURL(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func didBack() {
        webView.goBack()
    }

    func didForward() {
        webView.goForward()
    }

    func didRefresh() {
        webView.reload()
    }

    func didStop() {
        webView.stopLoading()
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

}
