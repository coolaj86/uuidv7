import CryptoKit
import Foundation

let UUIDSize = 16
let SlideSize = 10

// UUIDv7 represented as 16 bytes
struct UUIDv7 {
    var bytes: [UInt8]
    private var buffer: [UInt8]
    private var cursor: Int

    init() {
        bytes = [UInt8](repeating: 0, count: UUIDSize)
        buffer = [UInt8](repeating: 0, count: 96) // can do 10 UUIDs before re-randomizing buffer
        cursor = buffer.count
    }

    mutating func generate() -> String {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        return generateAt(ms: now)
    }

    mutating func generateAt(ms: Int64) -> String {
        let bytes = generateBytesAt(ms: ms)
        let uuidv7 = UUIDv7.format(bytes: bytes)
        return uuidv7
    }

    mutating func generateBytesAt(ms: Int64) -> [UInt8] {
        var uuid = UUIDv7.nextSubarray(buffer: &buffer, cursor: &cursor)
        UUIDv7.fill(&uuid, ms: ms)
        let bytes = Array(uuid[0 ..< UUIDSize])
        return bytes
    }

    static func fill(_ uuid: inout [UInt8], ms: Int64) {
        let timeHigh = UInt32(ms >> 16) // the lower 32 bits (of the upper 48 bits)
        let timeLow = UInt16(ms & 0xFFFF) // the lower 16 bits

        uuid[0] = UInt8((timeHigh >> 24) & 0xFF)
        uuid[1] = UInt8((timeHigh >> 16) & 0xFF)
        uuid[2] = UInt8((timeHigh >> 8) & 0xFF)
        uuid[3] = UInt8(timeHigh & 0xFF)

        uuid[4] = UInt8((timeLow >> 8) & 0xFF)
        uuid[5] = UInt8(timeLow & 0xFF)

        // set top 4 bits to 0b0111 (0x7 for UUID v7)
        uuid[6] = (uuid[6] & 0x0F) | 0x70

        // set top 2 bits to 0b10 (RFC 4122 UUID variant)
        uuid[8] = (uuid[8] & 0x3F) | 0x80
    }

    static func format(bytes: [UInt8]) -> String {
        let hexStr = bytes.map { String(format: "%02x", $0) }.joined()

        let part1 = hexStr.prefix(8)
        let part2 = hexStr.dropFirst(8).prefix(4)
        let part3 = hexStr.dropFirst(12).prefix(4)
        let part4 = hexStr.dropFirst(16).prefix(4)
        let part5 = hexStr.suffix(12)

        return "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"
    }

    static func setBuffer(bytes: [UInt8], buffer: inout [UInt8], cursor: inout Int) throws {
        guard bytes.count >= UUIDSize else {
            struct BufferTooSmallError: LocalizedError {
                var errorDescription: String? { "Minimum UUIDv7 buffer size is \(UUIDSize) bytes" }
            }
            throw BufferTooSmallError()
        }
        buffer = bytes
        cursor = buffer.count
    }

    // Advances the random buffer cursor, potentially refilling the buffer
    static func nextSubarray(buffer: inout [UInt8], cursor: inout Int) -> [UInt8] {
        cursor += 10
        var end = cursor + UUIDSize
        if end > buffer.count {
            _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
            cursor = 0
            end = UUIDSize
        }
        return Array(buffer[cursor ..< cursor + UUIDSize])
    }
}
