package employee

import (
	"context"
	"strings"

	"backend/config"

	"github.com/gofiber/fiber/v3"
)

type CreateMyEmployeeProfileRequest struct {
	DepartmentID *int64 `json:"department_id"`

	EmployeeCode string `json:"employee_code"`
	FullName     string `json:"full_name"`
	Position     string `json:"position"`
	Phone        string `json:"phone"`
	AvatarURL    string `json:"avatar_url"`
}

func CreateMyEmployeeProfile(c fiber.Ctx) error {
	var body CreateMyEmployeeProfileRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request body",
		})
	}

	body.EmployeeCode = strings.TrimSpace(body.EmployeeCode)
	body.FullName = strings.TrimSpace(body.FullName)
	body.Position = strings.TrimSpace(body.Position)
	body.Phone = strings.TrimSpace(body.Phone)
	body.AvatarURL = strings.TrimSpace(body.AvatarURL)

	if body.EmployeeCode == "" || body.FullName == "" || body.Position == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Employee code, full name, and position are required",
		})
	}

	userID, ok := c.Locals("user_id").(int64)
	if !ok {
		return c.Status(401).JSON(fiber.Map{
			"message": "Unauthorized",
		})
	}

	var existingEmployeeID int64

	err := config.DB.QueryRow(
		context.Background(),
		`
		SELECT id
		FROM employees
		WHERE user_id = $1
		`,
		userID,
	).Scan(&existingEmployeeID)

	if err == nil {
		return c.Status(409).JSON(fiber.Map{
			"message": "Employee profile already exists",
		})
	}

	var employeeID int64

	err = config.DB.QueryRow(
		context.Background(),
		`
		INSERT INTO employees 
		(user_id, department_id, employee_code, full_name, position, phone, avatar_url)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id
		`,
		userID,
		body.DepartmentID,
		body.EmployeeCode,
		body.FullName,
		body.Position,
		body.Phone,
		body.AvatarURL,
	).Scan(&employeeID)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not create employee profile",
			"error":   err.Error(),
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"message": "Employee profile created successfully",
		"data": fiber.Map{
			"id":            employeeID,
			"user_id":       userID,
			"department_id": body.DepartmentID,
			"employee_code": body.EmployeeCode,
			"full_name":     body.FullName,
			"position":      body.Position,
			"phone":         body.Phone,
			"avatar_url":    body.AvatarURL,
		},
	})
}
