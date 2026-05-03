package officelocation

import (
	"backend/config"
	"context"
	"strings"

	"github.com/gofiber/fiber/v3"
)

type CreateOfficeLocationRequest struct {
	Name                string  `json:"name"`
	Latitude            float64 `json:"latitude"`
	Longitude           float64 `json:"longitude"`
	AllowedRadiusMeters int     `json:"allowed_radius_meters"`
}

func CreateOfficeLocation(c fiber.Ctx) error {
	var body CreateOfficeLocationRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request body",
		})
	}

	body.Name = strings.TrimSpace(body.Name)

	if body.Name == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Name is required",
		})
	}

	var existingName string

	err := config.DB.QueryRow(context.Background(), `SELECT name FROM office_locations WHERE name = $1`, body.Name).Scan(&existingName)

	if err == nil {
		return c.Status(409).JSON(fiber.Map{
			"message": "Office Location already exists",
		})
	}

	var ID int64

	err = config.DB.QueryRow(
		context.Background(),
		`
		INSERT INTO office_locations (name, latitude, longitude, allowed_radius_meters)
		VALUES ($1, $2, $3, $4)
		RETURNING id
		`,
		body.Name,
		body.Latitude,
		body.Longitude,
		body.AllowedRadiusMeters,
	).Scan(&ID)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not create office location",
			"error":   err.Error(),
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"message": "Office location created successfully",
		"data": fiber.Map{
			"id":                    ID,
			"name":                  body.Name,
			"latitude":              body.Latitude,
			"longitude":             body.Longitude,
			"allowed_radius_meters": body.AllowedRadiusMeters,
		},
	})
}
