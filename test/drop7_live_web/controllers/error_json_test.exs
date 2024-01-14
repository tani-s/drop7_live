defmodule Drop7LiveWeb.ErrorJSONTest do
  use Drop7LiveWeb.ConnCase, async: true

  test "renders 404" do
    assert Drop7LiveWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Drop7LiveWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
