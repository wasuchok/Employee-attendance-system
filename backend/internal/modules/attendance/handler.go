package attendance

import (
	"backend/config"
	"context"
	"math"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/jackc/pgx/v5"
)

type CreateAttendanceRequest struct {
	OfficeLocationID int64   `json:"office_location_id"`
	CheckInLatitude  float64 `json:"check_in_latitude"`
	CheckInLongitude float64 `json:"check_in_longitude"`
	Note             string  `json:"note"`
}

type AttendanceResponse struct {
	ID                 int64     `json:"id"`
	EmployeeID         int64     `json:"employee_id"`
	OfficeLocationID   int64     `json:"office_location_id"`
	OfficeLocationName string    `json:"office_location_name"`
	AttendanceDate     time.Time `json:"attendance_date"`
	CheckInTime        time.Time `json:"check_in_time"`
	CheckInLatitude    float64   `json:"check_in_latitude"`
	CheckInLongitude   float64   `json:"check_in_longitude"`
	DistanceMeters     float64   `json:"distance_meters"`
	Note               string    `json:"note"`
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

	var existingAttendanceID int64
	err = config.DB.QueryRow(
		ctx,
		`SELECT id
		FROM attendances
		WHERE employee_id = $1
			AND attendance_date = CURRENT_DATE
		LIMIT 1`,
		employeeID,
	).Scan(&existingAttendanceID)

	if err == nil {
		return c.Status(409).JSON(fiber.Map{
			"message": "Already checked in today",
		})
	}

	if err != pgx.ErrNoRows {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not check existing attendance",
			"error":   err.Error(),
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
			"error":   err.Error(),
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

func GetTodayAttendance(c fiber.Ctx) error {
	employeeID, err := getEmployeeIDFromToken(c)
	if err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var result AttendanceResponse

	err = config.DB.QueryRow(
		ctx,
		`SELECT
			a.id,
			a.employee_id,
			a.office_location_id,
			o.name,
			a.attendance_date,
			a.check_in_time,
			a.check_in_latitude,
			a.check_in_longitude,
			a.distance_meters,
			COALESCE(a.note, '')
		FROM attendances a
		JOIN office_locations o ON o.id = a.office_location_id
		WHERE a.employee_id = $1
			AND a.attendance_date = CURRENT_DATE
		ORDER BY a.check_in_time DESC
		LIMIT 1`,
		employeeID,
	).Scan(
		&result.ID,
		&result.EmployeeID,
		&result.OfficeLocationID,
		&result.OfficeLocationName,
		&result.AttendanceDate,
		&result.CheckInTime,
		&result.CheckInLatitude,
		&result.CheckInLongitude,
		&result.DistanceMeters,
		&result.Note,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			return c.JSON(fiber.Map{
				"message": "No attendance record found for today",
				"data":    nil,
			})
		}

		return c.Status(500).JSON(fiber.Map{
			"message": "Could not fetch today's attendance",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Today's attendance fetched successfully",
		"data":    result,
	})
}

func GetAttendanceHistory(c fiber.Ctx) error {
	employeeID, err := getEmployeeIDFromToken(c)
	if err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := config.DB.Query(
		ctx,
		`SELECT
			a.id,
			a.employee_id,
			a.office_location_id,
			o.name,
			a.attendance_date,
			a.check_in_time,
			a.check_in_latitude,
			a.check_in_longitude,
			a.distance_meters,
			COALESCE(a.note, '')
		FROM attendances a
		JOIN office_locations o ON o.id = a.office_location_id
		WHERE a.employee_id = $1
		ORDER BY a.attendance_date DESC, a.check_in_time DESC
		LIMIT 30`,
		employeeID,
	)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not fetch attendance history",
		})
	}

	defer rows.Close()

	results := make([]AttendanceResponse, 0)

	for rows.Next() {
		var result AttendanceResponse

		if err := rows.Scan(
			&result.ID,
			&result.EmployeeID,
			&result.OfficeLocationID,
			&result.OfficeLocationName,
			&result.AttendanceDate,
			&result.CheckInTime,
			&result.CheckInLatitude,
			&result.CheckInLongitude,
			&result.DistanceMeters,
			&result.Note,
		); err != nil {
			return c.Status(500).JSON(fiber.Map{
				"message": "Could not scan attendance history",
			})
		}

		results = append(results, result)
	}

	if err := rows.Err(); err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Error during attendance history iteration",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Attendance history fetched successfully",
		"data":    results,
	})
}

func getEmployeeIDFromToken(c fiber.Ctx) (int64, error) {
	userID, ok := c.Locals("user_id").(int64)
	if !ok {
		return 0, c.Status(401).JSON(fiber.Map{
			"message": "Unauthorized",
		})
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var employeeID int64

	err := config.DB.QueryRow(
		ctx,
		`SELECT id FROM employees WHERE user_id = $1`,
		userID,
	).Scan(&employeeID)

	if err != nil {
		return 0, c.Status(404).JSON(fiber.Map{
			"message": "Employee profile not found",
		})
	}

	return employeeID, nil
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
