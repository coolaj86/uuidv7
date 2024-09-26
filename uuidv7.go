package uuidv7

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"sync"
	"time"
)

const (
	UUIDSize  = 16
	SlideSize = 10
)

var (
	buffer = make([]byte, 96) // 10 uuids before refill
	cursor = len(buffer)
	mutex  sync.Mutex
)

// UUIDv7 in byte form, 16 bytes
type UUIDv7 []byte

// New generates a new slice of UUIDv7 bytes using the given or current time.
func New() UUIDv7 {
	now := time.Now().UnixMilli()

	return NewWithTime(now)
}

// NewWithTime allows specifying a custom time
func NewWithTime(ms int64) UUIDv7 {
	mutex.Lock()
	defer mutex.Unlock()

	uuid := nextSubarray()

	ms64 := ms
	Fill(uuid, ms64)

	copied := make([]byte, 16, 16)
	copy(copied, uuid[:UUIDSize])
	return copied
}

// String returns the UUIDv7 bytes as a UUID-formatted string
func (u UUIDv7) String() string {
	return Format(u)
}

// Fill sets a pre-randomized byte array with the lower 48 bits of the given time.
func Fill(uuid UUIDv7, ms64 int64) {
	timeHigh := int32(ms64 >> 16)
	timeLow := int16(ms64 & 0xffff)

	// High 32 bits of time
	uuid[0] = byte(timeHigh >> 24)
	uuid[1] = byte(timeHigh >> 16)
	uuid[2] = byte(timeHigh >> 8)
	uuid[3] = byte(timeHigh)

	// Low 16 bits of time
	uuid[4] = byte(timeLow >> 8)
	uuid[5] = byte(timeLow)

	// Set the top 4 bits to 0b0111 (0x7 for UUID v7)
	uuid[6] = (uuid[6] & 0x0f) | 0x70

	// Set the top 2 bits to 0b10 (RFC 4122 UUID variant)
	uuid[8] = (uuid[8] & 0x3f) | 0x80
}

// Format encodes a 16-byte array as UUID.
func Format(bytes []byte) string {
	hexStr := hex.EncodeToString(bytes)

	return fmt.Sprintf("%s-%s-%s-%s-%s",
		hexStr[0:8],
		hexStr[8:12],
		hexStr[12:16],
		hexStr[16:20],
		hexStr[20:32],
	)
}

// SetBuffer changes the buffer to one of the size of your choosing
func SetBuffer(bytes []byte) error {
	mutex.Lock()
	defer mutex.Unlock()

	if len(bytes) < UUIDSize {
		return errors.New(fmt.Sprintf("minimum UUIDv7 buffer size is %d bytes", UUIDSize))
	}
	buffer = bytes
	cursor = len(buffer)
	return nil
}

// nextSubarray advances the random buffer cursor, potentially refilling the buffer.
func nextSubarray() []byte {
	cursor += 10
	end := cursor + UUIDSize
	if end > len(buffer) {
		_, _ = rand.Read(buffer)
		cursor = 0
		end = UUIDSize
	}

	return buffer[cursor:end]
}
