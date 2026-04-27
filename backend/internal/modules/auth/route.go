package auth

import "github.com/gofiber/fiber/v3"

func RegisterRoutes(app *fiber.App) {
	auth := app.Group("/api/auth")

	auth.Post("/register", Register)
	auth.Post("/login", Login)
	auth.Post("/refresh", RefreshToken)
	auth.Post("/logout", Logout)
}
