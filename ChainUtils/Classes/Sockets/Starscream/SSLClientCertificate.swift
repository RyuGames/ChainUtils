//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  SSLClientCertificate.swift
//  Starscream
//
//  Created by Tomasz Trela on 08/03/2018.
//  Copyright © 2018 Vluxe. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

public struct SSLClientCertificateError: LocalizedError {
    public var errorDescription: String?
    
    init(errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

public class SSLClientCertificate {
    internal let streamSSLCertificates: NSArray

    /**
     Convenience init.
     - parameter pkcs12Path: Path to pkcs12 file containing private key and X.509 ceritifacte (.p12)
     - parameter password: file password, see **kSecImportExportPassphrase**
     */
    public convenience init(pkcs12Path: String, password: String) throws {
        let pkcs12Url = URL(fileURLWithPath: pkcs12Path)
        do {
            try self.init(pkcs12Url: pkcs12Url, password: password)
        } catch {
            throw error
        }
    }
    
    /**
     Designated init. For more information, see SSLSetCertificate() in Security/SecureTransport.h.
     - parameter identity: SecIdentityRef, see **kCFStreamSSLCertificates**
     - parameter identityCertificate: CFArray of SecCertificateRefs, see **kCFStreamSSLCertificates**
     */
    public init(identity: SecIdentity, identityCertificate: SecCertificate) {
        self.streamSSLCertificates = NSArray(objects: identity, identityCertificate)
    }
    
    /**
     Convenience init.
     - parameter pkcs12Url: URL to pkcs12 file containing private key and X.509 ceritifacte (.p12)
     - parameter password: file password, see **kSecImportExportPassphrase**
     */
    public convenience init(pkcs12Url: URL, password: String) throws {
        let importOptions = [kSecImportExportPassphrase as String : password] as CFDictionary
        do {
            try self.init(pkcs12Url: pkcs12Url, importOptions: importOptions)
        } catch {
            throw error
        }
    }
    
    /**
     Designated init.
     - parameter pkcs12Url: URL to pkcs12 file containing private key and X.509 ceritifacte (.p12)
     - parameter importOptions: A dictionary containing import options. A
     kSecImportExportPassphrase entry is required at minimum. Only password-based
     PKCS12 blobs are currently supported. See **SecImportExport.h**
     */
    public init(pkcs12Url: URL, importOptions: CFDictionary) throws {
        do {
            let pkcs12Data = try Data(contentsOf: pkcs12Url)
            var rawIdentitiesAndCertificates: CFArray?
            let pkcs12CFData: CFData = pkcs12Data as CFData
            let importStatus = SecPKCS12Import(pkcs12CFData, importOptions, &rawIdentitiesAndCertificates)
            
            guard importStatus == errSecSuccess else {
                throw SSLClientCertificateError(errorDescription: "(Starscream) Error during 'SecPKCS12Import', see 'SecBase.h' - OSStatus: \(importStatus)")
            }
            guard let identitiyAndCertificate = (rawIdentitiesAndCertificates as? Array<Dictionary<String, Any>>)?.first else {
                throw SSLClientCertificateError(errorDescription: "(Starscream) Error - PKCS12 file is empty")
            }
            
            let identity = identitiyAndCertificate[kSecImportItemIdentity as String] as! SecIdentity
            var identityCertificate: SecCertificate?
            let copyStatus = SecIdentityCopyCertificate(identity, &identityCertificate)
            guard copyStatus == errSecSuccess else {
                throw SSLClientCertificateError(errorDescription: "(Starscream) Error during 'SecIdentityCopyCertificate', see 'SecBase.h' - OSStatus: \(copyStatus)")
            }
            self.streamSSLCertificates = NSArray(objects: identity, identityCertificate!)
        } catch {
            throw error
        }
    }
}
