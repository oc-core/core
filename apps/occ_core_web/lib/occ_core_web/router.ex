# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCCWeb.Router do
  use OCCWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OCCWeb do
    pipe_through :api
  end
end
