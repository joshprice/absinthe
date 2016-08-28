defmodule Absinthe.Blueprint.Input.Boolean do

  alias Absinthe.Phase

  @enforce_keys [:value]
  defstruct [
    :value,
    :source_location,
    # Added by phases
    flags: [],
    schema_node: nil,
    errors: [],
  ]

  @type t :: %__MODULE__{
    value: true | false,
    flags: [atom],
    schema_node: nil | Absinthe.Type.t,
    source_location: Blueprint.Document.SourceLocation.t,
    errors: [Phase.Error.t],
  }

end
