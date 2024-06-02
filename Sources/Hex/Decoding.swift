public enum DecodingError: Swift.Error {
    case invalidCharacterCount
    case invalidCharacter
}

extension [UInt8] {
    public init(hexEncoded hexBytes: some Sequence<UInt8>) throws {
        self = try hexBytes.withContiguousStorageIfAvailable({
            try Self(hexEncoded: UnsafeRawBufferPointer($0))
        }) ?? Array(hexBytes).withUnsafeBytes({
            try Self(hexEncoded: $0)
        })
    }
    
    public init(hexEncoded hexString: String) throws {
        try self.init(hexEncoded: hexString.utf8)
    }
    
    public init(hexEncoded hexString: Substring) throws {
        try self.init(hexEncoded: hexString.utf8)
    }
    
    public init(hexEncoded hexBytes: UnsafeRawBufferPointer) throws {
        guard hexBytes.count.isMultiple(of: 2) else {
            throw DecodingError.invalidCharacterCount
        }
        try self.init(unsafeUninitializedCapacity: hexBytes.count / 2, initializingWith: {
            $0.initialize(repeating: 0)
            try UnsafeMutableRawBufferPointer($0).decodeHexBytes(from: hexBytes)
            $1 = hexBytes.count / 2
        })
    }
}

extension UnsafeMutableRawBufferPointer {
    public func decodeHexBytes(from source: UnsafeRawBufferPointer) throws {
        precondition(count * 2 == source.count, "TODO")
        
        let step = 8
        let roundedCount = count & -step
        var offset = 0
        
        while offset < roundedCount {
            let hexBytes = source.loadUnaligned(
                fromByteOffset: offset &* 2,
                as: SIMD16<UInt8>.self
            )
            self.storeBytes(
                of: try hexBytes.decodingHexBytes(),
                toByteOffset: offset,
                as: SIMD8<UInt8>.self
            )
            offset &+= step
        }
        
        while offset < count {
            let hexBytes = source.loadUnaligned(
                fromByteOffset: offset &* 2,
                as: SIMD2<UInt8>.self
            )
            self.storeBytes(
                of: try hexBytes.decodingHexBytes(),
                toByteOffset: offset,
                as: UInt8.self
            )
            offset &+= 1
        }
        
        assert(offset == count)
    }
}

extension SIMD16<UInt8> {
    fileprivate func decodingHexBytes() throws -> SIMD8<UInt8> {
        let a = self &- 0x30
        let isDigit = a .< 0x0a
        let b = (self | Self(repeating: 0b0010_0000)) &- 0x61
        let isLetter = b .< 0x07
        let c = b &+ 0x0a
        var d = Self.zero
        d.replace(with: a, where: isDigit)
        d.replace(with: c, where: isLetter)
        guard Self.one.replacing(
            with: Self.zero,
            where: isDigit .^ isLetter
        ).wrappedSum() == 0 else {
            throw DecodingError.invalidCharacter
        }
        return d.evenHalf &<< 4 | d.oddHalf
    }
}

extension SIMD2<UInt8> {
    fileprivate func decodingHexBytes() throws -> UInt8 {
        let a = self &- 0x30
        let isDigit = a .< 0x0a
        let b = (self | Self(repeating: 0b0010_0000)) &- 0x61
        let isLetter = b .< 0x07
        let c = b &+ 0x0a
        var d = Self.zero
        d.replace(with: a, where: isDigit)
        d.replace(with: c, where: isLetter)
        guard Self.one.replacing(
            with: Self.zero,
            where: isDigit .^ isLetter
        ).wrappedSum() == 0 else {
            throw DecodingError.invalidCharacter
        }
        return d[0] &<< 4 | d[1]
    }
}
