//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MercadoPagoService: NSObject {

    let MP_DEFAULT_TIME_OUT = 15.0

    var baseURL: String!
    init (baseURL: String) {
        super.init()
        self.baseURL = baseURL
    }
    override init () {
        super.init()
    }

    public func request(uri: String, params: String?, body: String?, method: String, headers: [String:String]? = nil, cache: Bool = true, success: @escaping (_ jsonResult: AnyObject?) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        var url = baseURL + uri
        var requesturl = url
        if !String.isNullOrEmpty(params) {
            requesturl += "?" + params!
        }

        let finalURL: NSURL = NSURL(string: requesturl)!
        let request: NSMutableURLRequest
        if cache {
            request  = NSMutableURLRequest(url: finalURL as URL,
                                           cachePolicy: .returnCacheDataElseLoad, timeoutInterval: MP_DEFAULT_TIME_OUT)
        } else {
            request = NSMutableURLRequest(url: finalURL as URL,
                                          cachePolicy: .useProtocolCachePolicy, timeoutInterval: MP_DEFAULT_TIME_OUT)
        }

        #if DEBUG
            print("\n--REQUEST_URL: \(finalURL)")
        #endif

        request.url = finalURL as URL
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body = body {
            #if DEBUG
                print("--REQUEST_BODY: \(body as! NSString)")
            #endif
            request.httpBody = body.data(using: String.Encoding.utf8)
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response: URLResponse?, data: Data?, error: Error?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error == nil {
                do {
                    #if DEBUG
                        print("--REQUEST_RESPONSE: \(String(data: data!, encoding: String.Encoding.utf8) as! NSString)\n")
                    #endif
                    let responseJson = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
                    success(responseJson as AnyObject?)
                } catch {

                    let e: NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
                    failure?(e)
                }
            } else {
                failure?(error! as NSError)
            }
        }
    }
}
