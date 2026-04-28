package employee

import (
	"backend/internal/modules/auth"

	"github.com/gofiber/fiber/v3"
)

func RegisterEmployeeRoutes(app *fiber.App) {
	employees := app.Group("/api/employees")

	employees.Post("/me", auth.Protected(), CreateMyEmployeeProfile)
	employees.Get("/me", auth.Protected(), GetMyEmployeeProfile)
}
