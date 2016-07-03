defmodule Absinthe.Language.InputObjectTypeDefinition do
  @moduledoc false

  alias Absinthe.{Blueprint, Language}

  defstruct [
    name: nil,
    fields: [],
    directives: [],
    loc: %{start_line: nil},
    errors: [],
  ]

  @type t :: %__MODULE__{
    name: String.t,
    fields: [Language.InputValueDefinition.t],
    directives: [Language.Directive.t],
    loc: Language.loc_t,
  }

  defimpl Blueprint.Draft do
    def convert(node, doc) do
      %Blueprint.IDL.InputObjectTypeDefinition{
        name: node.name,
        fields: Absinthe.Blueprint.Draft.convert(node.fields, doc),
        directives: Absinthe.Blueprint.Draft.convert(node.directives, doc),
      }
    end
  end

end
