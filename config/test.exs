import Config

config :drop7_live, Drop7LiveWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rGGl0f8Xp3xAhitN+8z4V7KRCis3VYCxas3le92lGxidbP+Zf2ANK7idcVS+Y+oh",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
