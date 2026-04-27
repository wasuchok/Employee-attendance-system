package routes

import (
	"backend/internal/handlers"

	"github.com/gofiber/fiber/v3"
)

func AuthRoutes(app *fiber.App) {
	auth := app.Group("/api/auth")

	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)
	auth.Post("/refresh", handlers.RefreshToken)
}
