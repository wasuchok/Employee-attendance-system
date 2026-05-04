package officelocation

import (
	"backend/internal/modules/auth"

	"github.com/gofiber/fiber/v3"
)

func RegisterOfficeLocationRoutes(app *fiber.App) {
	office_locations := app.Group("/api/office_locations")

	office_locations.Post("/create", auth.Protected(), auth.AdminOnly(), CreateOfficeLocation)
	office_locations.Get("/lists", GetOfficeLocation)
}
