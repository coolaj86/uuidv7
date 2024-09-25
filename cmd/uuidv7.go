package main

import (
	"fmt"

	"github.com/coolaj86/uuidv7"
)

func main() {
	uuid := uuidv7.New()
	fmt.Println(uuid.String())
}
