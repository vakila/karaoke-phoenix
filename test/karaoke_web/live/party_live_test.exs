defmodule KaraokeWeb.PartyLiveTest do
  use KaraokeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Karaoke.PartiesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_party(_) do
    party = party_fixture()

    %{party: party}
  end

  describe "Index" do
    setup [:create_party]

    test "lists all parties", %{conn: conn, party: party} do
      {:ok, _index_live, html} = live(conn, ~p"/parties")

      assert html =~ "Listing Parties"
      assert html =~ party.name
    end

    test "saves new party", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/parties")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Party")
               |> render_click()
               |> follow_redirect(conn, ~p"/parties/new")

      assert render(form_live) =~ "New Party"

      assert form_live
             |> form("#party-form", party: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#party-form", party: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/parties")

      html = render(index_live)
      assert html =~ "Party created successfully"
      assert html =~ "some name"
    end

    test "updates party in listing", %{conn: conn, party: party} do
      {:ok, index_live, _html} = live(conn, ~p"/parties")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#parties-#{party.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/parties/#{party}/edit")

      assert render(form_live) =~ "Edit Party"

      assert form_live
             |> form("#party-form", party: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#party-form", party: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/parties")

      html = render(index_live)
      assert html =~ "Party updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes party in listing", %{conn: conn, party: party} do
      {:ok, index_live, _html} = live(conn, ~p"/parties")

      assert index_live |> element("#parties-#{party.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#parties-#{party.id}")
    end
  end

  describe "Show" do
    setup [:create_party]

    test "displays party", %{conn: conn, party: party} do
      {:ok, _show_live, html} = live(conn, ~p"/parties/#{party}")

      assert html =~ "Show Party"
      assert html =~ party.name
    end

    test "updates party and returns to show", %{conn: conn, party: party} do
      {:ok, show_live, _html} = live(conn, ~p"/parties/#{party}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/parties/#{party}/edit?return_to=show")

      assert render(form_live) =~ "Edit Party"

      assert form_live
             |> form("#party-form", party: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#party-form", party: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/parties/#{party}")

      html = render(show_live)
      assert html =~ "Party updated successfully"
      assert html =~ "some updated name"
    end
  end
end
