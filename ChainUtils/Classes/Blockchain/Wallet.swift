//
//  Wallet.swift
//  ChainUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2021 Ryu Games. All rights reserved.
//

import UIKit
import Neoutils
import CommonCrypto

public final class Wallet: NSObject, Codable {
    public var address: String = ""
    public var wif: String = ""
    public var privateKey: Data = Data()
    public var publicKey: Data = Data()
    public var privateKeyString: String = ""
    public var publicKeyString: String = ""
    private var neoWallet: NeoutilsWallet?
    public var neoPrivateKey: Data? {
        return neoWallet?.privateKey
    }

    public init(address: String, wif: String, privateKey: Data, publicKey: Data, neoWallet: NeoutilsWallet) {
        super.init()
        self.address = address
        self.wif = wif
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.privateKeyString = privateKey.bytesToHex
        self.publicKeyString = publicKey.bytesToHex
        self.neoWallet = neoWallet
    }

    private enum CodingKeys: String, CodingKey {
        case address = "address"
        case publicKey = "publicKey"
        case publicKeyString = "publicKeyString"
        case wif = "wif"
        case privateKey = "privateKey"
        case privateKeyString = "privateKeyString"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(publicKeyString, forKey: .publicKeyString)
        try container.encode(wif, forKey: .wif)
        try container.encode(privateKey, forKey: .privateKey)
        try container.encode(privateKeyString, forKey: .privateKeyString)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .address)
        self.publicKey = try container.decode(Data.self, forKey: .publicKey)
        self.publicKeyString = try container.decode(String.self, forKey: .publicKeyString)
        self.wif = try container.decode(String.self, forKey: .wif)
        self.privateKey = try container.decode(Data.self, forKey: .privateKey)
        self.privateKeyString = try container.decode(String.self, forKey: .privateKeyString)
        if self.wif != "" {
            self.neoWallet = NeoutilsGenerateFromWIF(self.wif, NSErrorPointer(nilLiteral: ()))
        }
    }

    public func toData() -> Data? {
        let data = try? JSONEncoder().encode(self)
        return data
    }

    public func signMessage(message: String) -> String? {
        let error = NSErrorPointer(nilLiteral: ())
        let data = Data(message.utf8)
        if let neoWallet = neoWallet {
            let sig = NeoutilsSign(data, neoWallet.privateKey!.bytesToHex, error)?.bytesToHex
            return sig
        }
        return nil
    }

    public func signData(data: Data) -> Data? {
        let error = NSErrorPointer(nilLiteral: ())
        if let neoWallet = neoWallet {
            return NeoutilsSign(data, neoWallet.privateKey!.bytesToHex, error)
        }
        return nil
    }

    public func verifySignature(signature: String, message: String) -> Bool {
        let data = Data(message.utf8)
        let hash = sha256(data)
        return NeoutilsVerify(publicKey, signature.hexToBytes, hash)
    }

    public func computeSharedSecret(publicKey: Data) -> Data? {
        if let neoWallet = neoWallet {
            return neoWallet.computeSharedSecret(publicKey)
        }
        return nil
    }

    public func computeSharedSecret(publicKey: String) -> Data? {
        if let neoWallet = neoWallet {
            return neoWallet.computeSharedSecret(publicKey.hexToBytes)
        }
        return nil
    }

    public func privateEncrypt(message: String) -> String? {
        if let neoWallet = neoWallet {
            return NeoutilsEncrypt(neoWallet.privateKey, message)
        }
        return nil
    }

    public func privateDecrypt(encrypted: String) -> String? {
        if let neoWallet = neoWallet {
            return NeoutilsDecrypt(neoWallet.privateKey, encrypted)
        }
        return nil
    }

    public func sharedEncrypt(message: String, publicKey: Data) -> String {
        let secretKey = computeSharedSecret(publicKey: publicKey)
        return NeoutilsEncrypt(secretKey, message)
    }

    public func sharedDecrypt(encrypted: String, publicKey: Data) -> String {
        let secretKey = computeSharedSecret(publicKey: publicKey)
        return NeoutilsDecrypt(secretKey, encrypted)
    }
}

// MARK: - ENUMs
public enum KeyType {
    case PrivateKey
    case NEOPrivateKey
    case NEP2
    case WIF
    case Address
    case PublicKey
}

// MARK: - PUBLIC FUNCTIONS

public func newWallet() -> Wallet {
    let wallet = walletFromOntAccount(ontAccount: NeoutilsONTCreateAccount()!)
    return wallet
}

public func walletFromWIF(wif: String) -> Wallet? {
    guard let ontAccount = NeoutilsONTAccountFromWIF(wif) else {
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}

public func walletFromPrivateKey(privateKey: Data) -> Wallet? {
    let count = privateKey.count
    if count == 32 {
        return walletFromNEOPrivateKey(privateKey: privateKey)
    } else if count == 67 {
        return walletFromONTPrivateKey(privateKey: privateKey)
    } else {
        return nil
    }
}

public func walletFromPrivateKey(privateKey: String) -> Wallet? {
    guard let p = privateKey.hexToBytes else {
        return nil
    }
    return walletFromPrivateKey(privateKey: p)
}

public func newEncryptedKey(wif: String, password: String) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let nep2 = NeoutilsNEP2Encrypt(wif, password, error)
    return nep2?.encryptedKey
}

public func wifFromEncryptedKey(encrypted: String, password: String) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let wif = NeoutilsNEP2Decrypt(encrypted, password, error)
    return wif
}

public func addressFromWif(wif: String) -> String? {
    guard let wallet = walletFromWIF(wif: wif) else {
        return nil
    }
    return wallet.address
}

public func publicKeyFromWif(wif: String) -> String? {
    guard let wallet = walletFromWIF(wif: wif) else {
        return nil
    }
    return wallet.publicKeyString
}

public func publicKeyFromPrivateKey(privateKey: String) -> String? {
    guard let wallet = walletFromPrivateKey(privateKey: privateKey) else {
        return nil
    }
    return wallet.publicKeyString
}

public func addressFromPublicKey(publicKey: Data) -> String {
    return NeoutilsONTAddressFromPublicKey(publicKey)
}

public func addressFromPublicKey(publicKey: String) -> String {
    guard let p = publicKey.hexToBytes else {
        return ""
    }
    return addressFromPublicKey(publicKey: p)
}

public func same(a: Wallet, b: Wallet) -> Bool {
    return a.address == b.address && a.publicKeyString == b.publicKeyString && a.wif == b.wif && a.privateKeyString == b.privateKeyString && a.neoPrivateKey?.bytesToHex == b.neoPrivateKey?.bytesToHex
}

// MARK: - PRIVATE FUNCTIONS

private func sha256(_ data: Data) -> Data {
    let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!
    CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
}

private func walletFromOntAccount(ontAccount: NeoutilsONTAccount) -> Wallet {
    let err = NSErrorPointer(nilLiteral: ())
    let w = Wallet(address: ontAccount.address,
                   wif: ontAccount.wif,
                   privateKey: ontAccount.privateKey!,
                   publicKey: ontAccount.publicKey!,
                   neoWallet: NeoutilsGenerateFromWIF(ontAccount.wif, err)!)
    return w
}

private func walletFromNEOPrivateKey(privateKey: Data) -> Wallet? {
    let p = privateKey.bytesToHex
    return walletFromNEOPrivateKey(privateKey: p)
}

private func walletFromNEOPrivateKey(privateKey: String) -> Wallet? {
    let err = NSErrorPointer(nilLiteral: ())
    // The private key format has already been checked so we can force-cast
    let neoWallet = NeoutilsGenerateFromPrivateKey(privateKey, err)!
    let ontAccount = NeoutilsONTAccountFromWIF(neoWallet.wif)!
    let w = Wallet(address: ontAccount.address,
                   wif: ontAccount.wif,
                   privateKey: ontAccount.privateKey!,
                   publicKey: ontAccount.publicKey!,
                   neoWallet: neoWallet)
    return w
}

private func walletFromONTPrivateKey(privateKey: Data) -> Wallet? {
    guard let ontAccount = NeoutilsONTAccountFromPrivateKey(privateKey) else {
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}
