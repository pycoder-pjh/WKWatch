//
//  ViewController.swift
//  WKWatch
//
//  Created by Palle, Jagadeeswaraiah(AWF) on 20/07/1939 Saka.
//  Copyright © 1939 Saka PayPal. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var container: UIView!
   
    var webView : WKWebView!
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanges(note:)), name:.reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("reachability not started")
        }
        
        let source = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        
        let script = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true

        let userController = WKUserContentController()
        userController.addUserScript(script)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        
        webView = WKWebView(frame: self.container.bounds, configuration:configuration)
//        webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
//        print("...........................",webView.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        
        // loading URL
        let WatchURL = "PLACE YOUR DESIRED URL HERE"
        let Wurl = NSURL(string: WatchURL)
        let request = NSURLRequest(url: Wurl! as URL)
        webView.load(request as URLRequest)
        

        self.container.addSubview(webView)
        self.container.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
//        self.view.sendSubview(toBack: webView)
    }
    
    func internetChanges(note:Notification){
        let reachability = note.object as! Reachability
        
        if reachability.connection == .wifi || reachability.connection == .cellular{
            print("network reachable")
        }else{
            print("network not reachable.. try again")
            let alert = UIAlertController(title: "No Internet Connection", message: "Please..Make sure device is connected to Internet and VPN", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(result:UIAlertAction) -> Void in self.webView.reload()})
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
}

