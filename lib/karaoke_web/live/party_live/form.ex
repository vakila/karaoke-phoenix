defmodule KaraokeWeb.PartyLive.Form do
  use KaraokeWeb, :live_view

  alias Karaoke.Parties
  alias Karaoke.Parties.Party

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage party records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="party-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Party</.button>
          <.button navigate={return_path(@return_to, @party)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    party = Parties.get_party!(id)

    socket
    |> assign(:page_title, "Edit Party")
    |> assign(:party, party)
    |> assign(:form, to_form(Parties.change_party(party)))
  end

  defp apply_action(socket, :new, _params) do
    party = %Party{}

    socket
    |> assign(:page_title, "New Party")
    |> assign(:party, party)
    |> assign(:form, to_form(Parties.change_party(party)))
  end

  @impl true
  def handle_event("validate", %{"party" => party_params}, socket) do
    changeset = Parties.change_party(socket.assigns.party, party_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"party" => party_params}, socket) do
    save_party(socket, socket.assigns.live_action, party_params)
  end

  defp save_party(socket, :edit, party_params) do
    case Parties.update_party(socket.assigns.party, party_params) do
      {:ok, party} ->
        {:noreply,
         socket
         |> put_flash(:info, "Party updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, party))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_party(socket, :new, party_params) do
    case Parties.create_party(party_params) do
      {:ok, party} ->
        {:noreply,
         socket
         |> put_flash(:info, "Party created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, party))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _party), do: ~p"/parties"
  defp return_path("show", party), do: ~p"/parties/#{party}"
end
