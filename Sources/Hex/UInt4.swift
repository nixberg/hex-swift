struct UInt4 {
    fileprivate let rawValue: UInt8
    
    init(rawValue: UInt8) {
        assert(rawValue == rawValue & 0b0000_1111)
        self.rawValue = rawValue
    }
    
    init?(hexEncoded hexByte: UInt8) {
        switch hexByte {
        case UInt8(ascii: "0")...UInt8(ascii: "9"):
            self.init(rawValue: hexByte - UInt8(ascii: "0"))
        case UInt8(ascii: "A")...UInt8(ascii: "F"):
            self.init(rawValue: hexByte - UInt8(ascii: "A") + 0x0a)
        case UInt8(ascii: "a")...UInt8(ascii: "f"):
            self.init(rawValue: hexByte - UInt8(ascii: "a") + 0x0a)
        default:
            return nil
        }
    }
    
    func hexEncodedByte(usingUppercaseCharacters useUppercaseCharacters: Bool) -> UInt8 {
        if rawValue < 0xa {
            rawValue + UInt8(ascii: "0")
        } else {
            if useUppercaseCharacters {
                rawValue + UInt8(ascii: "A") - 0xa
            } else {
                rawValue + UInt8(ascii: "a") - 0xa
            }
        }
    }
}

extension UInt8 {
    var nibbles: (high: UInt4, low: UInt4) {
        (high: UInt4(rawValue: self >> 4), low: UInt4(rawValue: self & 0b0000_1111))
    }
    
    init(nibbles: (high: UInt4, low: UInt4)) {
        self = nibbles.high.rawValue << 4 | nibbles.low.rawValue
    }
}
