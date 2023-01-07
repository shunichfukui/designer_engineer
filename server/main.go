package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/greeting", func(c *gin.Context) {
		greeting := "hello world"
		c.JSON(200, gin.H{
			"message": greeting,
		})
	})
	r.Run()
}
