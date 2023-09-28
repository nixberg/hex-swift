extension Sequence<UInt8> {
    public func hexEncodedBytes(
        usingUppercaseCharacters useUppercaseCharacters: Bool = false
    ) -> HexEncodedBytesSequence<Self> {
        HexEncodedBytesSequence(base: self, useUppercaseCharacters: useUppercaseCharacters)
    }
    
    public func hexEncodedString(
        usingUppercaseCharacters useUppercaseCharacters: Bool = false
    ) -> String {
        // TODO: Use SE-0405 String Initializer when available.
        String(self.hexEncodedBytes(usingUppercaseCharacters: useUppercaseCharacters).lazy.map({
            Character(Unicode.Scalar($0))
        }))
    }
}

public struct HexEncodedBytesSequence<Base: Sequence<UInt8>> {
    fileprivate let base: Base
    fileprivate let useUppercaseCharacters: Bool
}

extension HexEncodedBytesSequence: Sequence {
    public struct Iterator: IteratorProtocol {
        private var iterator: Base.Iterator
        private var nextNibble: UInt4? = nil
        private let useUppercaseCharacters: Bool
        
        fileprivate init(iterator: Base.Iterator, useUppercaseCharacters: Bool) {
            self.iterator = iterator
            self.useUppercaseCharacters = useUppercaseCharacters
        }
        
        public mutating func next() -> UInt8? {
            if let nextNibble {
                self.nextNibble = nil
                return nextNibble.hexEncodedByte(usingUppercaseCharacters: useUppercaseCharacters)
            }
            guard let nibbles = iterator.next()?.nibbles else {
                return nil
            }
            nextNibble = nibbles.low
            return nibbles.high.hexEncodedByte(usingUppercaseCharacters: useUppercaseCharacters)
        }
    }
    
    public var underestimatedCount: Int {
        base.underestimatedCount * 2
    }
    
    public func makeIterator() -> Iterator {
        Iterator(iterator: base.makeIterator(), useUppercaseCharacters: useUppercaseCharacters)
    }
}
