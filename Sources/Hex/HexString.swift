@propertyWrapper
public struct HexString: Codable {
    public var wrappedValue: String {
        didSet {
            projectedValue = wrappedValue.projectedValue()
        }
    }
    public private(set) var projectedValue: [UInt8]
    
    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
        projectedValue = wrappedValue.projectedValue()
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(wrappedValue: decoder.singleValueContainer().decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension String {
    fileprivate func dropAll(where isExcluded: (Element) throws -> Bool) rethrows -> Self {
        try self.filter({ try !isExcluded($0) })
    }
    
    fileprivate func projectedValue() -> [UInt8] {
        guard let projectedValue = try? Array(
            hexEncoded: self.dropAll(where: \.isWhitespace)
        ) else {
            preconditionFailure("TODO")
        }
        return projectedValue
    }
}
