defmodule Absinthe.Test.InvalidInputTypes do
  use Absinthe.Schema

  object :user do
  end

  input_object :input do
  end

  object :bad_object do
    field :blah, :input
  end

  input_object :bad_input_object do
    field :person, :user
  end

  query do
    field :foo, :user do
      arg :invalid_arg, :user
      arg :invalid_nested_arg, :bad_input_object
    end
  end

end
