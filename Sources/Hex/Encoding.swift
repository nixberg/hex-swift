extension Sequence<UInt8> {
    public func hexEncodedBytes(uppercase: Bool = false) -> HexEncodedBytesSequence<Self> {
        HexEncodedBytesSequence(base: self, uppercase: uppercase)
    }
    
    public func hexEncodedString(uppercase: Bool = false) -> String {
        // TODO: Use SE-0405 String Initializer when available.
        String(self.hexEncodedBytes(uppercase: uppercase).lazy.map({
            Character(Unicode.Scalar($0))
        }))
    }
}

public struct HexEncodedBytesSequence<Base: Sequence<UInt8>> {
    fileprivate let base: Base
    fileprivate let uppercase: Bool
}

extension HexEncodedBytesSequence: Sequence {
    public struct Iterator: IteratorProtocol {
        private var iterator: Base.Iterator
        private var nextNibble: UInt4? = nil
        private let uppercase: Bool
        
        fileprivate init(iterator: Base.Iterator, uppercase: Bool) {
            self.iterator = iterator
            self.uppercase = uppercase
        }
        
        public mutating func next() -> UInt8? {
            if let nextNibble {
                self.nextNibble = nil
                return nextNibble.hexEncodedByte(uppercase: uppercase)
            }
            guard let nibbles = iterator.next()?.nibbles else {
                return nil
            }
            nextNibble = nibbles.low
            return nibbles.high.hexEncodedByte(uppercase: uppercase)
        }
    }
    
    public var underestimatedCount: Int {
        base.underestimatedCount * 2
    }
    
    public func makeIterator() -> Iterator {
        Iterator(iterator: base.makeIterator(), uppercase: uppercase)
    }
}
