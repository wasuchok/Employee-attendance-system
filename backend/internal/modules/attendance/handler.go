package attendance

import (
	"backend/config"
	"context"
	"math"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
)

type CreateAttendanceRequest struct {
	OfficeLocationID int64   `json:"office_location_id"`
	CheckInLatitude  float64 `json:"check_in_latitude"`
	CheckInLongitude float64 `json:"check_in_longitude"`
	Note             string  `json:"note"`
}

func CreateAttendance(c fiber.Ctx) error {
	var body CreateAttendanceRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request body",
		})
	}

	userID, ok := c.Locals("user_id").(int64)
	if !ok {
		return c.Status(401).JSON(fiber.Map{
			"message": "Unauthorized",
		})
	}

	body.Note = strings.TrimSpace(body.Note)

	if body.OfficeLocationID <= 0 {
		return c.Status(400).JSON(fiber.Map{"message": "office_location_id is required"})
	}

	if body.CheckInLatitude < -90 || body.CheckInLatitude > 90 {
		return c.Status(400).JSON(fiber.Map{"message": "invalid check_in_latitude"})
	}

	if body.CheckInLongitude < -180 || body.CheckInLongitude > 180 {
		return c.Status(400).JSON(fiber.Map{"message": "invalid check_in_longitude"})
	}

	var employeeID int64

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err := config.DB.QueryRow(
		ctx,
		`SELECT id FROM employees WHERE user_id = $1`,
		userID,
	).Scan(&employeeID)

	if err != nil {
		return c.Status(404).JSON(fiber.Map{
			"message": "Employee profile not found",
		})
	}

	var officeID int64
	var officeLatitude float64
	var officeLongitude float64
	var allowedRadiusMeters float64
	err = config.DB.QueryRow(
		ctx,
		`SELECT id, latitude, longitude, allowed_radius_meters
		FROM office_locations
		WHERE id = $1 AND is_active = true`,
		body.OfficeLocationID,
	).Scan(&officeID, &officeLatitude, &officeLongitude, &allowedRadiusMeters)

	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid office location",
		})
	}

	distanceMeters := haversineMeters(
		body.CheckInLatitude,
		body.CheckInLongitude,
		officeLatitude,
		officeLongitude,
	)

	if distanceMeters > allowedRadiusMeters {
		return c.Status(403).JSON(fiber.Map{
			"message": "Check-in location is outside allowed radius",
		})
	}

	var id int64
	var attendanceDate time.Time
	var checkInTime time.Time

	err = config.DB.QueryRow(
		ctx,
		`INSERT INTO attendances (
		employee_id,
		office_location_id,
		attendance_date,
			check_in_time,
			check_in_latitude,
			check_in_longitude,
			distance_meters,
			note
		) VALUES ($1, $2, CURRENT_DATE, NOW(), $3, $4, $5, $6)
		RETURNING id, attendance_date, check_in_time`,
		employeeID,
		body.OfficeLocationID,
		body.CheckInLatitude,
		body.CheckInLongitude,
		distanceMeters,
		body.Note,
	).Scan(&id, &attendanceDate, &checkInTime)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not create attendance",
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"message": "Attendance created successfully",
		"data": fiber.Map{
			"id":                 id,
			"employee_id":        employeeID,
			"office_location_id": body.OfficeLocationID,
			"attendance_date":    attendanceDate,
			"check_in_time":      checkInTime,
			"check_in_latitude":  body.CheckInLatitude,
			"check_in_longitude": body.CheckInLongitude,
			"distance_meters":    distanceMeters,
			"note":               body.Note,
		},
	})
}

func haversineMeters(lat1, lon1, lat2, lon2 float64) float64 {
	const earthRadiusMeters = 6371000.0

	toRadians := func(degrees float64) float64 {
		return degrees * math.Pi / 180.0
	}

	dLat := toRadians(lat2 - lat1)
	dLon := toRadians(lon2 - lon1)
	lat1Rad := toRadians(lat1)
	lat2Rad := toRadians(lat2)

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1Rad)*math.Cos(lat2Rad)*math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadiusMeters * c
}
