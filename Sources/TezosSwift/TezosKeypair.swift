import Foundation
import BIP39swift
import Ed25519
import CryptoSwift
import Base58Swift
import Blake2

public struct TezosPrefix {
    public static let edsk:[UInt8] = [43, 246, 78, 7]
    public static let tz1:[UInt8] = [6, 161, 159]
    public static let edsig:[UInt8] = [9, 245, 205, 134, 18]
    public static let sig:[UInt8] = [4, 130, 43]
}

public struct TezosKeypair {
    public var mnemonics: String?
    
    public var derivePath: String?
    
    public var secretKey: Data
    
    private var keyPair:Ed25519KeyPair?
    
    public var privateKey: String {
        return Base58.base58CheckEncode(TezosPrefix.edsk + secretKey.bytes)
    }
    
    public var publicKey: Data {
        return self.keyPair!.publicKey.raw
    }
    
    public var publicKeyHash: Data? {
        guard let hashedData = self.genericHash(messageData: publicKey, outputLength: 20)else {
            return nil
        }
        return hashedData
    }
    
    public var address:String {
        guard let _publicKeyHash = publicKeyHash else {
            return ""
        }
        return Self.publicKeyHashToAddress(publicKeyHash: _publicKeyHash)
    }
    
    public init(secretKey: Data) {
        self.secretKey = secretKey
        self.keyPair = try! Ed25519KeyPair(raw:secretKey)
    }
    
    public init(privateKey:String) throws {
        guard let privateBytes = Base58.base58CheckDecode(privateKey) else {
            throw Error.invalidPrivateKey
        }
        self.init(secretKey:Data(privateBytes[4..<privateBytes.endIndex]))
    }
    
    public init(seed: Data)throws {
        let ed25519KeyPair = try Ed25519KeyPair(seed: Ed25519Seed(raw: seed))
        self.init(secretKey: ed25519KeyPair.raw)
    }
    
    public init(mnemonics: String, path: String = "m/44'/1729'/0'/0'") throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
        let (derivedSeed,_) = TezosKeypair.ed25519DeriveKey(path: path, seed: mnemonicSeed)
        try self.init(seed: derivedSeed)
        self.mnemonics = mnemonics
        self.derivePath = path
    }
    
    public static func randomKeyPair() throws -> TezosKeypair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw TezosKeypair.Error.invalidMnemonic
        }
        return try TezosKeypair(mnemonics: mnemonic)
    }
    
    public static func ed25519DeriveKey(path: String, seed: Data) -> (key: Data, chainCode: Data) {
        return Ed25519KeyPair.deriveKey(path: path, seed: seed)
    }
    
    public static func ed25519DeriveKey(path: String, key: Data, chainCode: Data) -> (key: Data, chainCode: Data) {
        return Ed25519KeyPair.deriveKey(path: path, key: key, chainCode: chainCode)
    }
}

extension TezosKeypair {
    
    public static func publicKeyHashToAddress(publicKeyHash:Data) -> String {
        let addressBytes = TezosPrefix.tz1+publicKeyHash.bytes
        return Base58.base58CheckEncode(addressBytes)
    }
    
    public static func addressToPublicKeyHash(address:String) -> Data? {
        guard let addressBytes = Base58.base58CheckDecode(address) else {
            return nil
        }
        return Data(addressBytes[3..<addressBytes.endIndex])
    }
}

// MARK: - Sign&Verify

extension TezosKeypair {
    public func signDigest(messageDigest:Data) -> Data {
        return try! Ed25519KeyPair(raw:self.secretKey).sign(message: messageDigest).raw
    }
    
    public func verifyPublickey(message: Data, signature: Data) -> Bool {
        return try! Ed25519KeyPair(raw:self.secretKey).verify(message: message, signature: Ed25519Signature(raw: signature))
    }
    
    public func genericHash(messageData:Data,outputLength:Int) -> Data? {
        let messageBytes = messageData.bytes
        guard let hash = try? Blake2.hash(.b2b, size: outputLength, bytes: messageBytes) else {
            return nil
        }
        return hash
    }
}

extension TezosKeypair {
    public enum Error: String, LocalizedError {
        case invalidMnemonic
        case invalidDerivePath
        case invalidPrivateKey
        case unknown
        
        public var errorDescription: String? {
            return "TezosKeypair.Error.\(rawValue)"
        }
    }
}
