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
        
        webView.frame = self.view.bounds
        webView.navigationDelegate = self
        webView.multipleTouchEnabled = true
        webView.scrollView.alwaysBounceVertical = true
        self.view.addSubview(webView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.progressView.frame.size.height)
        progressView.trackTintColor = UIColor(white: 1, alpha: 0)
        self.view.addSubview(progressView)
        
        backBarButton = UIBarButtonItem(image: R.image.backbutton, style: .Plain, target: self, action: Selector("didBack"))
        forwardBarButton = UIBarButtonItem(image: R.image.forwardbutton, style: .Plain, target: self, action: Selector("didForward"))
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("didRefresh"))
        stopBarButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector("didStop"))
        flexibleSpaceBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        backBarButton.width = 44
        forwardBarButton.width = 44

        updateToolBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func updateToolBar() {
        backBarButton.enabled = webView.canGoBack
        forwardBarButton.enabled = webView.canGoForward
        self.toolbarItems = [backBarButton, forwardBarButton, flexibleSpaceBarButton, webView.loading ? stopBarButton : refreshBarButton]
        self.navigationItem.title = webView.title
    }
    
    func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func loadURLString(urlString: String) {
        loadURL(NSURL(string: urlString)!)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1
            let animated = webView.estimatedProgress > Double(progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated:animated)

            // Once complete, fade out UIProgressView
            if webView.estimatedProgress >= 1.0 {
                UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.progressView.alpha = 0.0
                    }, completion: { (_) in
                        self.progressView.setProgress(0.0, animated:false)
                })
            }
        }
    }

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolBar()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        updateToolBar()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolBar()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolBar()
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .LinkActivated {
            loadURL(navigationAction.request.URL!)
            decisionHandler(.Cancel)
        } else {
            decisionHandler(.Allow)
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
