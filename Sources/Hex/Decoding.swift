extension RangeReplaceableCollection<UInt8> {
    public init?(hexEncoded hexBytes: some Sequence<UInt8>) {
        self.init()
        self.reserveCapacity(hexBytes.underestimatedCount / 2)
        var iterator = hexBytes.makeIterator()
        while let high = iterator.next() {
            guard let high = UInt4(hexEncoded: high),
                  let low = iterator.next(),
                  let low = UInt4(hexEncoded: low) else {
                return nil
            }
            self.append(Element(nibbles: (high, low)))
        }
    }
    
    public init?(hexEncoded hexString: some StringProtocol) {
        self.init(hexEncoded: hexString.utf8)
    }
}
