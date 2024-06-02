import SIMDExtras

extension [UInt8] {
    public func encodeHexBytes(to target: UnsafeMutableRawBufferPointer, uppercase: Bool = false) {
        self.withUnsafeBytes({ $0.encodeHexBytes(to: target, uppercase: uppercase) })
    }
    
    public func hexEncodedBytes(uppercase: Bool = false) -> Self {
        self.withUnsafeBytes({ $0.hexEncodedBytes(uppercase: uppercase) })
    }
    
    public func hexEncodedString(uppercase: Bool = false) -> String {
        self.withUnsafeBytes({ $0.hexEncodedString(uppercase: uppercase) })
    }
}

extension UnsafeRawBufferPointer {
    public func encodeHexBytes(to target: UnsafeMutableRawBufferPointer, uppercase: Bool = false) {
        precondition(target.count == count * 2, "TODO")
        
        let step = 8
        let roundedCount = count & -step
        var offset = 0
        
        while offset < roundedCount {
            let bytes = self.loadUnaligned(fromByteOffset: offset, as: SIMD8<UInt8>.self)
            target.storeBytes(
                of: bytes.hexEncoded(uppercase: uppercase),
                toByteOffset: offset &* 2,
                as: SIMD16<UInt8>.self
            )
            offset &+= step
        }
        
        while offset < count {
            let byte = self.load(fromByteOffset: offset, as: UInt8.self)
            target.storeBytes(
                of: byte.hexEncoded(uppercase: uppercase),
                toByteOffset: offset &* 2,
                as: SIMD2<UInt8>.self
            )
            offset &+= 1
        }
        
        assert(offset == count)
    }
    
    public func hexEncodedBytes(uppercase: Bool = false) -> [UInt8] {
        [UInt8](unsafeUninitializedCapacity: count * 2, initializingWith: {
            $0.initialize(repeating: 0)
            self.encodeHexBytes(to: UnsafeMutableRawBufferPointer($0), uppercase: uppercase)
            $1 = count * 2
        })
    }
    
    public func hexEncodedString(uppercase: Bool = false) -> String {
        guard #available(macOS 11.0, *) else {
            fatalError("TODO")
        }
        return String(unsafeUninitializedCapacity: count * 2, initializingUTF8With: {
            $0.initialize(repeating: 0)
            self.encodeHexBytes(to: UnsafeMutableRawBufferPointer($0), uppercase: uppercase)
            return count * 2
        })
    }
}

extension SIMD8<UInt8> {
    fileprivate func hexEncoded(uppercase: Bool) -> SIMD16<UInt8> {
        if uppercase {
            self.hexEncoded(withOffset: 0x37)
        } else {
            self.hexEncoded(withOffset: 0x57)
        }
    }
    
    private func hexEncoded(withOffset offset: _const Scalar) -> SIMD16<UInt8> {
        let nibbles = SIMD16(evenHalf: self &>> 4 & 0x0f, oddHalf: self & 0x0f)
        let offsets = SIMD16(repeating: offset).replacing(
            with: SIMD16(repeating: 0x30),
            where: nibbles .< 0x0a
        )
        return nibbles &+ offsets
    }
}

extension UInt8 {
    fileprivate func hexEncoded(uppercase: Bool) -> SIMD2<UInt8> {
        if uppercase {
            self.hexEncoded(withOffset: 0x37)
        } else {
            self.hexEncoded(withOffset: 0x57)
        }
    }
    
    private func hexEncoded(withOffset offset: _const Self) -> SIMD2<Self> {
        let nibbles = SIMD2(self &>> 4 & 0x0f, self & 0x0f)
        let offsets = SIMD2(repeating: offset).replacing(
            with: SIMD2(repeating: 0x30),
            where: nibbles .< 0x0a
        )
        return nibbles &+ offsets
    }
}
