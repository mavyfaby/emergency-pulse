package config

import (
	"time"

	"github.com/caarlos0/env/v11"
)

type Config struct {
	Port                  int           `env:"PORT,required"`
	TcpPort               int           `env:"TCP_PORT,required"`
	TZ                    string        `env:"TZ,required"`
	AlertRetries          int           `env:"ALERT_RETRIES,required"`
	AlertMaxRadius        int           `env:"ALERT_MAX_RADIUS,required"`
	EarthRadius           int           `env:"EARTH_RADIUS,required"`
	DBHost                string        `env:"DB_HOST,required"`
	DBPort                int           `env:"DB_PORT,required"`
	DBUser                string        `env:"DB_USER,required"`
	DBPass                string        `env:"DB_PASS,required"`
	DBName                string        `env:"DB_NAME,required"`
	DBMaxOpenConns        int           `env:"DB_MAX_OPEN_CONNS,required"`
	DBMaxIdleConns        int           `env:"DB_MAX_IDLE_CONNS,required"`
	DBConnMaxLifetime     time.Duration `env:"DB_CONN_MAX_LIFETIME,required"`
	RedisUsername         string        `env:"REDIS_USERNAME,required"`
	RedisPassword         string        `env:"REDIS_PASSWORD,required"`
	RedisDatabase         int           `env:"REDIS_DATABASE,required"`
	RedisHost             string        `env:"REDIS_HOST,required"`
	RedisPort             int           `env:"REDIS_PORT,required"`
	RedisStreamName       string        `env:"REDIS_STREAM_NAME,required"`
	RedisPoolSize         int           `env:"REDIS_POOL_SIZE,required"`
	RedisMinIdleConns     int           `env:"REDIS_MIN_IDLE_CONNS,required"`
	RedisPoolTimeout      time.Duration `env:"REDIS_POOL_TIMEOUT,required"`
	RedisIdleTimeout      time.Duration `env:"REDIS_IDLE_TIMEOUT,required"`
	RateLimitRefillPerSec int           `env:"RATE_LIMIT_REFILL_PER_SEC,required"`
	RateLimitMaxBurst     int           `env:"RATE_LIMIT_MAX_BURST,required"`
	RateLimitExpires      time.Duration `env:"RATE_LIMIT_EXPIRES,required"`
	HashSaltAlerts        string        `env:"HASH_SALT_ALERTS,required"`
}

var App Config

func (c Config) Load() error {
	return env.Parse(&App)
}
