package handlers

import (
	"backend/config"
	"backend/internal/utils"
	"context"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
)

type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func Register(c fiber.Ctx) error {
	var body RegisterRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request body",
		})
	}

	body.Email = strings.TrimSpace(strings.ToLower(body.Email))

	if body.Email == "" || body.Password == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Email and password are required",
		})
	}

	if len(body.Password) < 8 {
		return c.Status(400).JSON(fiber.Map{
			"message": "Password must be at least 8 characters",
		})
	}

	passwordHash, err := utils.HashPassword(body.Password)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not hash password",
		})
	}

	var userID int64

	err = config.DB.QueryRow(
		context.Background(),
		`
		INSERT INTO users (email, password_hash, role)
		VALUES ($1, $2, $3)
		RETURNING id
		`,
		body.Email,
		passwordHash,
		"employee",
	).Scan(&userID)

	if err != nil {
		return c.Status(409).JSON(fiber.Map{
			"message": "Email already exists",
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"message": "Register successful",
		"user": fiber.Map{
			"id":    userID,
			"email": body.Email,
			"role":  "employee",
		},
	})
}

func Login(c fiber.Ctx) error {
	var body LoginRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request body",
		})
	}

	body.Email = strings.TrimSpace(strings.ToLower(body.Email))

	var userID int64
	var email string
	var passwordHash string
	var role string
	var isActive bool

	err := config.DB.QueryRow(
		context.Background(),
		`
		SELECT id, email, password_hash, role, is_active
		FROM users
		WHERE email = $1
		`,
		body.Email,
	).Scan(&userID, &email, &passwordHash, &role, &isActive)

	if err != nil {
		return c.Status(401).JSON(fiber.Map{
			"message": "Invalid email or password",
		})
	}

	if !isActive {
		return c.Status(403).JSON(fiber.Map{
			"message": "User account is inactive",
		})
	}

	if !utils.CheckPasswordHash(body.Password, passwordHash) {
		return c.Status(401).JSON(fiber.Map{
			"message": "Invalid email or password",
		})
	}

	accessToken, err := utils.GenerateAccessToken(userID, email, role)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not generate access token",
		})
	}

	refreshToken, refreshExpiresAt, err := utils.GenerateRefreshToken(userID, email, role)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Could not generate refresh token",
		})
	}

	refreshTokenHash := utils.HashToken(refreshToken)

	_, err = config.DB.Exec(
		context.Background(),
		`
		INSERT INTO refresh_tokens
		(user_id, token_hash, expires_at, user_agent, ip_address)
		VALUES ($1, $2, $3, $4, $5)
		`,
		userID,
		refreshTokenHash,
		refreshExpiresAt,
		c.Get("User-Agent"),
		c.IP(),
	)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Could not save refresh token"})
	}

	return c.JSON(fiber.Map{
		"message": "Login successful",
		"user": fiber.Map{
			"id":    userID,
			"email": email,
			"role":  role,
		},
		"tokens": fiber.Map{
			"access_token":  accessToken,
			"refresh_token": refreshToken,
			"token_type":    "Bearer",
			"expires_in":    int64(15 * time.Minute / time.Second),
		},
	})
}

func RefreshToken(c fiber.Ctx) error {
	var body RefreshRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request",
		})
	}

	tokenHash := utils.HashToken(body.RefreshToken)

	var userID int64
	var email string
	var role string
	var expiresAt time.Time
	var revokedAt *time.Time

	err := config.DB.QueryRow(
		context.Background(),
		`
		SELECT rt.user_id, u.email, u.role, rt.expires_at, rt.revoked_at
		FROM refresh_tokens rt
		JOIN users u ON u.id = rt.user_id
		WHERE rt.token_hash = $1
		`,
		tokenHash,
	).Scan(&userID, &email, &role, &expiresAt, &revokedAt)

	if err != nil {
		return c.Status(401).JSON(fiber.Map{
			"message": "Invalid refresh token",
		})
	}

	if revokedAt != nil {
		return c.Status(401).JSON(fiber.Map{
			"message": "Token already revoked",
		})
	}

	if time.Now().After(expiresAt) {
		return c.Status(401).JSON(fiber.Map{
			"message": "Token expired",
		})
	}

	_, _ = config.DB.Exec(context.Background(),
		`UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = $1`,
		tokenHash,
	)

	newAccessToken, _ := utils.GenerateAccessToken(userID, email, role)
	newRefreshToken, newExpiresAt, _ := utils.GenerateRefreshToken(userID, email, role)

	newHash := utils.HashToken(newRefreshToken)

	_, _ = config.DB.Exec(context.Background(),
		`INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)`,
		userID,
		newHash,
		newExpiresAt,
	)

	return c.JSON(fiber.Map{
		"access_token":  newAccessToken,
		"refresh_token": newRefreshToken,
	})
}

func Logout(c fiber.Ctx) error {
	var body RefreshRequest

	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid request",
		})
	}

	hash := utils.HashToken(body.RefreshToken)

	_, err := config.DB.Exec(
		context.Background(),
		`
		UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = $1
		`, hash,
	)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Logout failed",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Logout success",
	})
}
