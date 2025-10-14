package db

import (
	"fmt"
	"log/slog"
	"net/url"
	"pulse/internal/config"

	_ "github.com/go-sql-driver/mysql"

	"github.com/jmoiron/sqlx"
)

func NewMariaDB() (*sqlx.DB, error) {
	// Get necessary database connection details
	var (
		dbUser         = config.App.DBUser
		dbPass         = config.App.DBPass
		dbHost         = config.App.DBHost
		dbPort         = config.App.DBPort
		dbName         = config.App.DBName
		dbMaxOpenConns = config.App.DBMaxOpenConns
		dbMaxIdleConns = config.App.DBMaxIdleConns
		dbMaxLifetime  = config.App.DBConnMaxLifetime
		timezone       = config.App.TZ
	)

	// Create the DSN string
	var dsn string = fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?parseTime=true&loc=%s", dbUser, dbPass, dbHost, dbPort, dbName, url.QueryEscape(timezone))

	// Open a new database connection
	conn, err := sqlx.Connect("mysql", dsn)

	// Check if the connection was successful
	if err != nil {
		slog.Error("Error connecting to the database:" + err.Error())
		return nil, err
	}

	// Ping the database to ensure it's reachable
	if err = conn.Ping(); err != nil {
		slog.Error("Error pinging the database:" + err.Error())
		return nil, err
	}

	// Set the maximum number of open and idle connections
	conn.SetMaxOpenConns(dbMaxOpenConns)
	// Set the maximum number of idle connections
	conn.SetMaxIdleConns(dbMaxIdleConns)
	// Set the maximum connection lifetime
	conn.SetConnMaxLifetime(dbMaxLifetime)

	// Log success
	slog.Info("[DB] MariaDB connection initialized!")

	// Return nil
	return conn, nil
}
