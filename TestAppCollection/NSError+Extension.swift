//
//  NSError+Extension.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 18.10.2021.
//

import UIKit

extension NSError {

    open class func error(with message: String, code: Int) -> NSError {
        NSError(domain: "\(Bundle.main.bundleIdentifier ?? "com.TestApp").error",
                code: code,
                userInfo: [NSLocalizedDescriptionKey : message])
    }
    
}
