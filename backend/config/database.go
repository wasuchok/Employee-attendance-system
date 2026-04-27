package config

import (
	"context"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

var DB *pgxpool.Pool

func ConnectDB() {
	dsn := os.Getenv("DATABASE_URL")

	db, err := pgxpool.New(context.Background(), dsn)

	if err != nil {
		log.Fatal("Unable to connect to database: ", err)
	}

	if err := db.Ping(context.Background()); err != nil {
		log.Fatal("Database ping failed: ", err)
	}

	DB = db

	log.Println("Database connected successfully")
}
