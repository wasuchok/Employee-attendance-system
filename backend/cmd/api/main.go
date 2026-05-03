package main

import (
	"backend/config"
	"backend/internal/modules/auth"
	"backend/internal/modules/employee"
	"backend/internal/modules/officelocation"
	"log"
	"os"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/logger"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	config.ConnectDB()

	app := fiber.New()
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${method} ${url} ${status} ${latency} - ${bytesSent}\n",
	}))

	app.Get("/health", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
		})
	})

	app.Get("/api/me", auth.Protected(), func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"user": fiber.Map{
				"id":    c.Locals("user_id"),
				"email": c.Locals("email"),
				"role":  c.Locals("role"),
			},
		})
	})

	auth.RegisterRoutes(app)
	employee.RegisterEmployeeRoutes(app)
	officelocation.RegisterOfficeLocationRoutes(app)

	port := os.Getenv("PORT")

	if port == "" {
		port = "3000"
	}

	log.Fatal(app.Listen(":" + port))
}
