extension RangeReplaceableCollection<UInt8> {
    public init?(hexEncoded hexBytes: some Sequence<UInt8>) {
        self.init()
        self.reserveCapacity(hexBytes.underestimatedCount / 2)
        var iterator = hexBytes.makeIterator()
        while let high = iterator.next() {
            guard let high = UInt4(hexEncoded: high),
                  let low = iterator.next(),
                  let low = UInt4(hexEncoded: low)
            else {
                return nil
            }
            self.append(Element(nibbles: (high, low)))
        }
    }
    
    public init?(hexEncoded hexString: some StringProtocol, skipWhitespace: Bool = false) {
        if skipWhitespace {
            self.init(hexEncoded: hexString.lazy.filter(\.isNotWhitespace).map(\.asciiValueOrNull))
        } else {
            self.init(hexEncoded: hexString.utf8)
        }
    }
    
    public init?(hexEncoded hexString: some StringProtocol, options: DecodingOptions) {
        self.init(hexEncoded: hexString, skipWhitespace: options.contains(.ignoreWhitespace))
    }
}

extension Character {
    fileprivate var isNotWhitespace: Bool {
        !isWhitespace
    }
    
    fileprivate var asciiValueOrNull: UInt8 {
        asciiValue ?? 0
    }
}

public struct DecodingOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let ignoreWhitespace = Self(rawValue: 1 << 0)
}
