defmodule Absinthe.Phase.Document.Validation.ArgumentsOfCorrectType do

  alias Absinthe.{Blueprint, Phase, Type}

  use Absinthe.Phase

  @spec run(Blueprint.t) :: Phase.result_t
  def run(input) do
    {result, _} = Blueprint.prewalk(input, input.schema, &handle_node/2)
    {:ok, result}
  end

  defp handle_node(%Blueprint.Input.Argument{schema_node: %{type: type_reference}, literal_value: literal, normalized_value: norm, data_value: nil} = node, schema) when not is_nil(norm) do
    type_identifier = Type.unwrap(type_reference)
    flags = [:invalid | node.flags]
    err = error(node, error_message(node, schema))
    {%{node | flags: flags, errors: [err | node.errors]}, schema}
  end
  defp handle_node(%Blueprint.Input.Object{} = node, schema) do
    if Enum.member?(node.flags, :invalid) do
      fields = Enum.map(node.fields, fn
        field ->
          if Enum.member?(field.flags, :invalid) do
            err = error(field, error_message(field, schema))
            field = %{field | errors: [err | field.errors]}
          end
      end)
      node = %{node | fields: Enum.reverse(fields)}
    end
    {node, schema}
  end
  defp handle_node(%Blueprint.Input.List{} = node, schema) do
    if Enum.member?(node.flags, :invalid) do
      values = Enum.map(node.values, fn
        value_node ->
          if Enum.member?(value_node.flags, :invalid) do
            err = error(value_node, error_message(value_node, schema))
            value_node = %{value_node | errors: [err | value_node.errors]}
          end
          value_node
      end)
      node = %{node | values: Enum.reverse(values)}
    end
    {node, schema}
  end
  defp handle_node(node, schema) do
    {node, schema}
  end

  defp error(node, message) do
    Phase.Error.new(
      __MODULE__,
      message,
      node.source_location
    )
  end

  defp error_message(%Blueprint.Input.Argument{} = node, schema) do
    error_message(node, node.schema_node.type, node.literal_value, schema)
  end
  defp error_message(node, schema) do
    error_message(node, node.schema_node, node, schema)
  end

  defp error_message(%Blueprint.Input.Field{}, nil, value, schema) do
    "Unknown field."
  end
  defp error_message(node, type, value, schema) do
    type_name = Type.name(type, schema)
    ~s(Expected type "#{type_name}", found #{Blueprint.Input.inspect value})
  end

end
