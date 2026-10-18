# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCCWeb.ErrorJSONTest do
  use OCCWeb.ConnCase, async: true

  test "renders 404" do
    assert OCCWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert OCCWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
