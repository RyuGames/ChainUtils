//
//  WalletTests.swift
//  ChainUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class WalletTests: XCTestCase {
    var exampleWallet: Wallet = newWallet()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddressFromPublicKey() {
        XCTAssertEqual(exampleWallet.address, addressFromPublicKey(publicKey: exampleWallet.publicKeyString))
        XCTAssertEqual("", addressFromPublicKey(publicKey: "1234"))
        XCTAssertEqual("", addressFromPublicKey(publicKey: ""))
    }

    func testBadOntKey() {
        let privateKeyStr = exampleWallet.privateKeyString
        let modified = privateKeyStr.dropFirst()
        let newPKS = "B\(modified)"
        guard let newPK = newPKS.hexToBytes else {
            XCTFail()
            return
        }
        let nWallet = walletFromPrivateKey(privateKey: newPK)
        XCTAssertNil(nWallet)
    }

    func testBadWif() {
        let wif = exampleWallet.wif
        let modified = wif.dropFirst()
        let newWif = "B\(modified)"
        let nWallet = walletFromWIF(wif: newWif)
        XCTAssertNil(nWallet)
    }

    func testBase58() {
        let address = newWallet().address
        let bad = address + "a"
        let hash = address.hashFromAddress()
        let badHash = bad.hashFromAddress()
        XCTAssertNotEqual("", hash)
        XCTAssertEqual("", badHash)
        XCTAssertEqual("", "BA".hashFromAddress())
        XCTAssertEqual("", "BAX".hashFromAddress())
        XCTAssertEqual("", "BADA".hashFromAddress())
        XCTAssertEqual("", "BA0102".hashFromAddress())
        XCTAssertEqual("", "BA234234234".hashFromAddress())
        XCTAssertEqual("", "a12312B123123123A".hashFromAddress())
        XCTAssertEqual("", "a12312B123123123Aa12312B123123123A".hashFromAddress())
        XCTAssertEqual("", "123242345235".hashFromAddress())
        XCTAssertEqual("", "DASDASDASDADA".hashFromAddress())
        XCTAssertEqual("", "EASEAESASEASEASE".hashFromAddress())
        XCTAssertEqual("", "D\(address)".hashFromAddress())
        XCTAssertEqual("", "1\(address)".hashFromAddress())
    }

    func testComparePrivateKeys() {
        for _ in 0..<5 {
            let wallet = newWallet()
            let ont = wallet.privateKey.count
            guard let neo = wallet.neoPrivateKey?.count else {
                XCTFail()
                return
            }

            if (neo > ont) {
                XCTFail()
                return
            }
        }
    }

    func testCompareWallet() {
        guard let a = walletFromWIF(wif: exampleWallet.wif) else {
            XCTFail()
            return
        }

        let ont = exampleWallet.privateKey
        guard let neo = exampleWallet.neoPrivateKey else {
            XCTFail()
            return
        }

        guard let b = walletFromPrivateKey(privateKey: ont) else {
            XCTFail()
            return
        }

        guard let c = walletFromPrivateKey(privateKey: neo) else {
            XCTFail()
            return
        }

        guard let d = walletFromPrivateKey(privateKey: exampleWallet.privateKeyString) else {
            XCTFail()
            return
        }

        let n = neo.bytesToHex
        guard let e = walletFromPrivateKey(privateKey: n) else {
            XCTFail()
            return
        }

        let a1 = a.address
        let a2 = b.address
        let a3 = c.address
        let a4 = d.address
        let a5 = e.address

        XCTAssert(a1 == a2)
        XCTAssert(a1 == a3)
        XCTAssert(a1 == a4)
        XCTAssert(a1 == a5)
        XCTAssertNotNil(a1)
        XCTAssertNotNil(a2)
        XCTAssertNotNil(a3)
        XCTAssertNotNil(a4)
        XCTAssertNotNil(a5)
    }

    func testData() {
        let a = newWallet()
        let b = a

        guard let d_a = a.toData() else {
            XCTFail()
            return
        }

        guard let d_b = b.toData() else {
            XCTFail()
            return
        }

        XCTAssertEqual(d_a, d_b)
        do {
            let w = try JSONDecoder().decode(Wallet.self, from: d_a)
            XCTAssertTrue(same(a: a, b: w))
        } catch {
            XCTFail()
        }
    }

    func testEncryptDecrypt() {
        let original = "Hello, world"
        guard let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        guard let encrypted = wallet.privateEncrypt(message: original) else {
            XCTFail()
            return
        }

        let decrypted = wallet.privateDecrypt(encrypted: encrypted)
        guard let encryptedString = wallet.privateEncrypt(message: original) else {
            XCTFail()
            return
        }

        let decryptedString = wallet.privateDecrypt(encrypted: encryptedString)

        XCTAssert(original == decrypted)
        XCTAssert(original == decryptedString)
    }

    func testInvalidKeys() {
        let p = "NOT A VALID PRIVATE KEY"
        let w = "NOT A VALID WIF"
        let data = Data()

        let a = walletFromPrivateKey(privateKey: p)
        let b = walletFromWIF(wif: w)
        let c = walletFromPrivateKey(privateKey: data)
        let addr = addressFromWif(wif: w)

        XCTAssertNil(a)
        XCTAssertNil(b)
        XCTAssertNil(c)
        XCTAssertNil(addr)
    }

    func testIsValidAddress() {
        XCTAssertTrue(exampleWallet.address.isValidAddress)
    }

    func testLockedWallet() {
        let a = newWallet()
        let asig = a.signMessage(message: "Welcome")
        XCTAssertNotNil(asig)
        let originalData = a.toData()
        let locked = a.lock(password: "123")
        XCTAssertTrue(locked)
        let second = a.lock(password: "456")
        XCTAssertFalse(second)
        let sig = a.signMessage(message: "Welcome")
        XCTAssertNil(sig)
        let signed = a.signData(data: originalData ?? Data())
        XCTAssertNil(signed)
        let publicKey = newWallet().publicKey
        let publicKeyString = newWallet().publicKeyString
        let shared = a.computeSharedSecret(publicKey: publicKey)
        XCTAssertNil(shared)
        let sharedString = a.computeSharedSecret(publicKey: publicKeyString)
        XCTAssertNil(sharedString)
        let enc = a.privateEncrypt(message: "XXX")
        XCTAssertNil(enc)
        let dec = a.privateDecrypt(encrypted: "XXX")
        XCTAssertNil(dec)
        let lockedData = a.toData()
        XCTAssertNotEqual(originalData, lockedData)
        let unlocked1 = a.unlock(password: "1234")
        XCTAssertFalse(unlocked1)
        let unlocked2 = a.unlock(password: "123")
        XCTAssertTrue(unlocked2)
        let unlocked3 = a.unlock(password: "123")
        XCTAssertFalse(unlocked3)
    }

    func testLocking() {
        let wallet = newWallet()
        let wif = wallet.wif
        let password = "password"

        XCTAssertEqual(wif, wallet.wif)
        XCTAssertFalse(wallet.locked)
        let locked = wallet.lock(password: password)
        XCTAssertTrue(locked)
        XCTAssertNotEqual(wif, wallet.wif)
        XCTAssertEqual("", wallet.wif)
        XCTAssertTrue(wallet.locked)

        guard let data = try? JSONEncoder().encode(wallet) else {
            XCTFail()
            return
        }

        do {
            let w = try JSONDecoder().decode(Wallet.self, from: data)
            XCTAssertNotEqual(wif, w.wif)
            XCTAssertEqual("", w.wif)
            XCTAssertTrue(w.locked)
            XCTAssertTrue(same(a: wallet, b: w))

            let unlocked = w.unlock(password: password)
            XCTAssertTrue(unlocked)
            XCTAssertEqual(wif, w.wif)
            XCTAssertNotEqual("", w.wif)
            XCTAssertFalse(w.locked)
            XCTAssertFalse(same(a: wallet, b: w))

            let unlocked2 = wallet.unlock(password: password)
            XCTAssertTrue(unlocked2)
            XCTAssertEqual(wif, wallet.wif)
            XCTAssertNotEqual("", wallet.wif)
            XCTAssertFalse(wallet.locked)
            XCTAssertTrue(same(a: wallet, b: w))
        } catch {
            XCTFail("\(error)")
        }
    }

    func testLockingIncorrectly() {
        let a = newWallet()
        a.wif = ""
        let locked = a.lock(password: "123")
        XCTAssertFalse(locked)
    }

    func testNEP2() {
        let password = "12345678"
        guard let e = newEncryptedKey(wif: exampleWallet.wif, password: password) else {
            XCTFail()
            return
        }

        let w = wifFromEncryptedKey(encrypted: e, password: password)
        XCTAssertTrue(w == exampleWallet.wif)
    }

    func testNewWallet() {
        let label = "Hello there!"
        let password = "12345"
        let wallet = newWallet(label: label, password: password)
        XCTAssertTrue(wallet.locked)
        XCTAssertEqual(wallet.wif, "")
        XCTAssertEqual(wallet.label, label)
        let unlocked = wallet.unlock(password: password)
        XCTAssertTrue(unlocked)
    }

    func testPublicKeyFrom() {
        guard let p1 = publicKeyFromWif(wif: exampleWallet.wif) else {
            XCTFail()
            return
        }

        guard let p2 = publicKeyFromPrivateKey(privateKey: exampleWallet.privateKeyString) else {
            XCTFail()
            return
        }

        XCTAssertEqual(p1, p2)
        let p3 = publicKeyFromWif(wif: "123")
        let p4 = publicKeyFromPrivateKey(privateKey: "123")
        XCTAssertNil(p3)
        XCTAssertNil(p4)
    }

    func testSharedSecret() {
        guard let a = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        let b = newWallet()

        guard let shared = b.computeSharedSecret(publicKey: a.publicKey) else {
            XCTFail()
            return
        }

        guard let shared2 = b.computeSharedSecret(publicKey: a.publicKeyString) else {
            XCTFail()
            return
        }

        XCTAssertEqual(shared, shared2)

        let original = "Hello, world"
        let encrypted = a.sharedEncrypt(message: original, publicKey: b.publicKey)
        let decrypted = a.sharedDecrypt(encrypted: encrypted, publicKey: b.publicKey)
        XCTAssertEqual(original, decrypted)
    }

    func testSign() {
        guard let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        let message = "Hello, world"
        guard let signature = wallet.signMessage(message: message) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(signature)
        let verified = wallet.verifySignature(signature: signature, message: message)
        XCTAssertTrue(verified)
        let notVerified = wallet.verifySignature(signature: signature, message: "\(message)1")
        XCTAssertFalse(notVerified)
    }

    func testWalletFromPK() {
        let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey)
        XCTAssertNotNil(wallet)
        let w = walletFromPrivateKey(privateKey: exampleWallet.privateKeyString)
        XCTAssertNotNil(w)
        let str = "123456789012345678901234567890"
        let data = str.data(using: .utf8)!
        let a = walletFromPrivateKey(privateKey: data)
        XCTAssertNil(a)
    }

    func testWalletFromWIF() {
        let _ = walletFromWIF(wif: exampleWallet.wif)
    }

    func testWif() {
        let str = "ABCDEFGHIJKLMNOPQRTSTUVWXYZ"
        let w1 = wifFromEncryptedKey(encrypted: str, password: "123")
        let wif = newWallet().wif
        guard let encrypted = newEncryptedKey(wif: wif, password: "123") else {
            XCTFail()
            return
        }
        let w2 = wifFromEncryptedKey(encrypted: encrypted, password: "456")
        let none = ""
        XCTAssertEqual(none, w1)
        XCTAssertEqual(none, w2)
        let enc2 = newEncryptedKey(wif: "", password: "")
        XCTAssertNil(enc2)
    }

}
