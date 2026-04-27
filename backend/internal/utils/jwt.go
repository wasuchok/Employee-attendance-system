package utils

import (
	"crypto/sha256"
	"encoding/hex"
	"os"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type Claims struct {
	UserID int64  `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

func GenerateAccessToken(userID int64, email string, role string) (string, error) {
	minutes, _ := strconv.Atoi(os.Getenv("ACCESS_TOKEN_EXPIRES_MINUTES"))
	if minutes == 0 {
		minutes = 15
	}

	claims := Claims{
		UserID: userID,
		Email:  email,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.NewString(),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Duration(minutes) * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(os.Getenv("JWT_ACCESS_SECRET")))
}

func GenerateRefreshToken(userID int64, email string, role string) (string, time.Time, error) {
	days, _ := strconv.Atoi(os.Getenv("REFRESH_TOKEN_EXPIRES_DAYS"))
	if days == 0 {
		days = 30
	}

	expiresAt := time.Now().Add(time.Duration(days) * 24 * time.Hour)

	claims := Claims{
		UserID: userID,
		Email:  email,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        uuid.NewString(),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	signedToken, err := token.SignedString([]byte(os.Getenv("JWT_REFRESH_SECRET")))
	return signedToken, expiresAt, err
}

func HashToken(token string) string {
	hash := sha256.Sum256([]byte(token))
	return hex.EncodeToString(hash[:])
}
