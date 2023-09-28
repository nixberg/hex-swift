@propertyWrapper
public struct HexEncodedString: Codable {
    public var wrappedValue: [UInt8]
    
    public var projectedValue: String {
        wrappedValue.hexEncodedString()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        guard let wrappedValue = Array(hexEncoded: hexString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "TODO")
        }
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(projectedValue)
    }
}
