package db

import (
	"context"
	"log/slog"
	"pulse/internal/config"
	"strconv"

	"github.com/redis/go-redis/v9"
)

func NewRedis() (*redis.Client, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     config.App.RedisHost + ":" + strconv.Itoa(config.App.RedisPort),
		Username: config.App.RedisUsername,
		Password: config.App.RedisPassword,
		DB:       config.App.RedisDatabase,
	})

	if _, err := client.Ping(context.Background()).Result(); err != nil {
		return nil, err
	}

	slog.Info("[DB] Redis connection initialized!")

	return client, nil
}
