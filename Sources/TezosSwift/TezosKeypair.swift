import Foundation
import BIP39swift
import TweetNacl
import CryptoSwift
import Base58Swift
import Blake2

public struct TezosPrefix {
    public static let edsk: [UInt8] = [43, 246, 78, 7]
    public static let tz1: [UInt8] = [6, 161, 159]
    public static let edsig: [UInt8] = [9, 245, 205, 134, 18]
    public static let sig: [UInt8] = [4, 130, 43]
}

public struct TezosAddress {
    public static let SIZE: Int = 20
    // PublicKey Hash
    public let data: Data
    
    public var address: String {
        let addressBytes = TezosPrefix.tz1 + data.bytes
        return addressBytes.base58CheckEncodedString
    }
    
    public init?(_ address: String) {
        guard let addressBytes = address.base58CheckDecodedData, addressBytes.count == TezosAddress.SIZE + TezosPrefix.tz1.count else {
            return nil
        }
        self.data = addressBytes.subdata(in: 3..<addressBytes.endIndex)
    }
    
    public init(_ data: Data) {
        self.data = data
    }
}

public struct TezosKeypair {
    public var mnemonics: String?
    public var derivePath: String?
    public var secretKey: Data
    public var publicKey: Data
    
    public var address: TezosAddress {
        let publicKeyHash = try! publicKey.genericHash(outputLength: TezosAddress.SIZE)
        return TezosAddress(publicKeyHash)
    }
    
    public var privateKey: String {
        let privateKeyBytes = TezosPrefix.edsk + secretKey.bytes
        return privateKeyBytes.base58CheckEncodedString
    }
    
    public init(secretKey: Data) throws {
        self.secretKey = secretKey
        self.publicKey = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey).publicKey
    }
    
    public init(privateKey: String) throws {
        guard let privateBytes = privateKey.base58CheckDecodedData else {
            throw Error.invalidPrivateKey
        }
        try self.init(secretKey:privateBytes.subdata(in: 4..<privateBytes.endIndex))
    }
    
    public init(seed: Data) throws {
        let secretKey = try NaclSign.KeyPair.keyPair(fromSeed: seed).secretKey
        try self.init(secretKey: secretKey)
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
        return NaclSign.KeyPair.deriveKey(path: path, seed: seed)
    }
    
    public static func ed25519DeriveKey(path: String, key: Data, chainCode: Data) -> (key: Data, chainCode: Data) {
        return NaclSign.KeyPair.deriveKey(path: path, key: key, chainCode: chainCode)
    }
}

// MARK: - Sign&Verify

extension TezosKeypair {
    public func signDigest(messageDigest: Data) throws -> Data {
        return try NaclSign.signDetached(message: messageDigest, secretKey: secretKey)
    }
    
    public func signVerify(messageDigest: Data, signature: Data) -> Bool {
        guard let ret = try? NaclSign.signDetachedVerify(message: messageDigest, sig: signature, publicKey: publicKey) else {
            return false
        }
        return ret
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
