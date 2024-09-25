package uuidv7_test

import (
	"fmt"
	"testing"

	"github.com/coolaj86/uuidv7"
)

func TestUUIDv7(t *testing.T) {
	// Test printing 10 UUIDv7 strings
	t.Run("Print 10 UUIDv7 strings", func(t *testing.T) {
		for i := 0; i < 10; i++ {
			uuid := uuidv7.New()
			fmt.Println(uuid.String())
		}
	})

	fmt.Println()

	// Test printing 10 UUIDv7 byte slices
	t.Run("Print 10 UUIDv7 byte slices", func(t *testing.T) {
		for i := 0; i < 10; i++ {
			uuidBytes := uuidv7.New()
			fmt.Println(uuidBytes)
		}
	})
}
