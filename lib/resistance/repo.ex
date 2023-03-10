defmodule Resistance.Repo do
  use Ecto.Repo,
    otp_app: :resistance,
    adapter: Ecto.Adapters.Postgres
end
