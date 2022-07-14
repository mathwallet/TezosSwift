import Foundation
public let defultSignature = "edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg"

/// Signed operation's data
public struct SignedRunOperationPayload: Encodable {
    public var contents: [TransactionOperation]
    public let branch: String
    public let signature: String

    public init(contents: [TransactionOperation], branch: String, signature: String = defultSignature) {
        self.contents = contents
        self.branch = branch
        self.signature = signature 
    }
}

