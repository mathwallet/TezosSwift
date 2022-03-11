import Foundation
import BIP39swift
import Ed25519
import CryptoSwift
import Base58Swift
import Sodium

struct TezosPrefix {
    static let edsk:[UInt8] = [43, 246, 78, 7]
    static let tz1:[UInt8] = [6, 161, 159]
}

public struct TezosKeypair {
    public var mnemonics: String?
    
    public var derivePath: String?
    
    private var keyPair:Ed25519KeyPair?
    
    public var secretKey: Data {
        return Data(TezosPrefix.edsk+self.keyPair!.raw.bytes)
    }
    
    public var privateKey: String {
        return Base58.base58CheckEncode(secretKey.bytes)
    }
    
    public var publicKey: Data {
        return self.keyPair!.publicKey.raw
    }
    
    public var publicKeyHash: Data? {
        guard let hashedBytes = Sodium().genericHash.hash(message:publicKey.bytes, outputLength: 20) else {
            return nil
        }
        return Data(hashedBytes)
    }
    
    public var address:String {
        guard let _publicKeyHash = publicKeyHash else {
            return ""
        }
        return Self.publicKeyHashToAddress(publicKeyHash: _publicKeyHash)
    }
    
    private init(keyPair: Ed25519KeyPair) {
        self.keyPair = keyPair
    }
    
    public init(secretKey: [UInt8]) throws {
        let scretKeyBytes = Array(secretKey[4..<secretKey.endIndex])
        let keyPair = try Ed25519KeyPair(raw: Data(scretKeyBytes))
        self.init(keyPair: keyPair)
    }
    
    public init?(privateKey:String) throws {
        guard let privateBytes = Base58.base58CheckDecode(privateKey) else {
            throw Error.invalidPrivateKey
        }
        try self.init(secretKey:privateBytes)
    }
    
    public init(seed: Data,path:String = "m/44'/1729'/0'/0'")throws {
        let (derivedSeed,_) = TezosKeypair.ed25519DeriveKey(path: path, seed: seed)
        let ed25519KeyPair = try Ed25519KeyPair(seed: Ed25519Seed(raw: derivedSeed))
        self.init(keyPair: ed25519KeyPair)
        self.derivePath = path
    }
    
    public init(mnemonics: String, path: String = "m/44'/1729'/0'/0'") throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
        try self.init(seed: mnemonicSeed)
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
