defmodule Absinthe.IR.Error do
  defstruct [
    message: nil,
    phase: nil,
  ]

  @type t :: %__MODULE__{
    message: binary,
    phase: atom,
  }
end
