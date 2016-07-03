defmodule Absinthe.Language.FieldDefinitionTest do
  use Absinthe.Case, async: true

  alias Absinthe.Blueprint

  @idl """
  type Foo {
    bar: [String!]!
    baz @description(text: "A directive on baz"): Int
    quuxes(limit: Int = 4): [Quux]
  }
  """

  describe "converting to Blueprint" do

    it "works, given an IDL object field definition" do
      {doc, fields} = fields_from_input(@idl)
      field_def = fields |> List.first |> Blueprint.Draft.convert(doc)
      assert %Blueprint.IDL.FieldDefinition{name: "bar", type: %Blueprint.NonNullType{of_type: %Blueprint.ListType{of_type: %Blueprint.NonNullType{of_type: %Blueprint.NamedType{name: "String"}}}}} = field_def
    end

    it "captures directives" do
      {doc, fields} = fields_from_input(@idl)
      field_def = fields |> Enum.at(1) |> Blueprint.Draft.convert(doc)
      assert %Blueprint.IDL.FieldDefinition{name: "baz"} = field_def
    end

    it "includes argument definitions" do
      {doc, fields} = fields_from_input(@idl)
      field_def = fields |> Enum.at(2) |> Blueprint.Draft.convert(doc)
      assert %Blueprint.IDL.FieldDefinition{name: "quuxes", type: %Blueprint.ListType{of_type: %Blueprint.NamedType{name: "Quux"}}, arguments: [%Blueprint.IDL.InputValueDefinition{name: "limit", type: %Blueprint.NamedType{name: "Int"}, default_value: %Blueprint.Input.Integer{value: 4}}]} == field_def
    end

  end

  defp fields_from_input(text) do
    {:ok, doc} = Absinthe.Phase.Parse.run(text)

    doc
    |> extract_fields
  end

  defp extract_fields(%Absinthe.Language.Document{definitions: definitions} = doc) do
    fields = definitions
    |> List.first
    |> Map.get(:fields)
    {doc, fields}
  end

end