package attendance

import (
	"backend/internal/modules/auth"

	"github.com/gofiber/fiber/v3"
)

func RegisterAttendanceRoutes(app *fiber.App) {
	attendances := app.Group("/api/attendances")

	attendances.Post("/check-in", auth.Protected(), CreateAttendance)
}
