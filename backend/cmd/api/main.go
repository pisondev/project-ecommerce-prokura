package main

import (
	"os"

	"prokura-api/internal/database"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
)

func init() {
	logrus.SetFormatter(&logrus.TextFormatter{
		FullTimestamp:   true,
		TimestampFormat: "2006-01-02 15:04:05",
	})
	logrus.SetOutput(os.Stdout)
}

func main() {
	if err := godotenv.Load(); err != nil {
		logrus.Warn("env file not found")
	}

	database.InitDB()

	app := fiber.New()

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "running",
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	logrus.Info("server starting")
	if err := app.Listen(":" + port); err != nil {
		logrus.Fatal("server failed")
	}
}
