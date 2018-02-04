defmodule Xema.NestedTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "list of objects in one schema" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            properties: %{
              id: {:number, minimum: 1},
              items: {
                :list,
                items: {
                  :map,
                  properties: %{
                    num: {:number, minimum: 0},
                    desc: :string
                  }
                }
              }
            }
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: 2, desc: "bar"}
        ]
      }

      assert validate(schema, data) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: -2, desc: "bar"}
        ]
      }

      error = {
        :error,
        %{
          items: [
            %{
              at: 1,
              error: %{
                num: %{value: -2, minimum: 0}
              }
            }
          ]
        }
      }

      assert validate(schema, data) == error
    end
  end

  describe "list of objects in two schemas" do
    setup do
      item =
        Xema.new(
          :map,
          properties: %{
            num: {:number, minimum: 0},
            desc: :string
          }
        )

      %{
        schema:
          Xema.new(
            :map,
            properties: %{
              id: {:number, minimum: 1},
              items: {:list, items: item}
            }
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: 2, desc: "bar"}
        ]
      }

      assert validate(schema, data) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      data = %{
        id: 6,
        items: [
          %{num: 1, desc: "foo"},
          %{num: -2, desc: "bar"}
        ]
      }

      error = {
        :error,
        %{
          items: [
            %{
              at: 1,
              error: %{
                num: %{value: -2, minimum: 0}
              }
            }
          ]
        }
      }

      assert validate(schema, data) == error
    end
  end
end
