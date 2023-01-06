defmodule Kanban.Data.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kanban.Data.{Task, Issue, Project}

  @type embeds_one(t) :: t

  @type t :: %__MODULE__{
          title: nil | String.t(),
          description: nil | String.t()
        }

  @primary_key false
  embedded_schema do
    field(:title, :string)
    field(:description, :string)
  end

  @spec changeset(Project.t(), any()) :: Ecto.Changeset.t()
  def changeset(project, params) do
    project
    |> cast(params, ~w[title description]a)
    |> validate_required(~w[title]a)
  end

  @spec create(any()) :: Project.t() | tuple()
  def create(params) when is_list(params),
    do: params |> Map.new() |> create()

  def create(params) when is_map(params) do
    %Project{}
    |> changeset(params)
    |> case do
      %Ecto.Changeset{valid?: false, errors: errors} -> {:error, errors}
      changeset -> apply_changes(changeset)
    end
  end

  def create(params),
    do: {:error, [unknown_params_type: params]}
end
