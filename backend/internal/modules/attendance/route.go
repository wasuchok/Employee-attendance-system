package attendance

import (
	"backend/internal/modules/auth"

	"github.com/gofiber/fiber/v3"
)

func RegisterAttendanceRoutes(app *fiber.App) {
	attendances := app.Group("/api/attendances")

	attendances.Post("/check-in", auth.Protected(), CreateAttendance)
	attendances.Post("/check-out", auth.Protected(), CheckOutAttendance)
	attendances.Get("/today", auth.Protected(), GetTodayAttendance)
	attendances.Get("/history", auth.Protected(), GetAttendanceHistory)
}
