defmodule Kanban.Data.Issue do
  use Ecto.Schema

  alias Kanban.Data.{Task, Issue, Project}

  import Ecto.Changeset

  @type embeds_one(t) :: [t]
  @type embeds_many(t) :: [t]

  @type t :: %__MODULE__{
    title: String.t(),
    description: String.t(),
    state: String.t(),
    type: String.t(),
    project: embeds_one(Project.t()),
    tasks: embeds_many(Task.t())
  }

  @primary_key false
  embedded_schema do
    field :title, :string
    field :description, :string
    field :state, :string, default: "idle"
    field :type, :string
    embeds_one :project, Project
    embeds_many :tasks, Task
  end

  @spec changeset(Issue.t(), any()) :: Ecto.Changeset.t()
  def changeset(issue, params) do
    issue
    |> cast(params, ~w[title description]a)
    |> cast_embed(:project, with: &Project.changeset/2)
    |> cast_embed(:tasks, with: &Task.changeset/2)
    |> validate_required(~w[title description]a)
    |> validate_inclusion(:type, ~w[bug feature]a)
    |> validate_inclusion(:state, ~w[idle ondoing done]a)
  end

  @spec create(any()) :: Issue.t() | tuple()
  def create(params) when is_list(params),
    do: params |> Map.new() |> create()

  @spec create(any()) :: Issue.t() | tuple()
  def create(params) when is_map(params) do
    %Issue{}
    |> changeset(params)
    |> case do
      %Ecto.Changeset{valid?: false, errors: errors} -> {:error, errors}
      changeset -> apply_changes(changeset)
    end
  end

  @spec create_default() :: Issue.t()
  def create_default do
    create(
      title: "Everything is so wrong.",
      description: "I think the best idea will be..",
      type: "feature"
    )
  end
end
