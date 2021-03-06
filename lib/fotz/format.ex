defmodule Fotz.Format do
  @moduledoc """
  Module that holds the format struct and compiles a template based on the
  struct data.
  """

  defstruct [
    :year,
    :month,
    :day,
    :hour,
    :minute,
    :second,
    :hash,
    :smallhash,
    :city,
    :state,
    :country,
    :camera,
    :ext,
    :original
  ]

  @typedoc """
  This is a basic struct that holds most of a file metadata so we can use it
  in order to generate a new filename. It will be used for the new copy of a
  file or as the new name of a moved file.
  """
  @type t :: %__MODULE__{
          year: String.t(),
          month: String.t(),
          day: String.t(),
          hour: String.t(),
          minute: String.t(),
          second: String.t(),
          hash: String.t(),
          smallhash: String.t(),
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          camera: String.t() | nil,
          ext: String.t(),
          original: String.t()
        }

  @doc """
  Compiles the mustache `template` with the `data`.
  """
  @spec compile(String.t(), t()) :: String.t()
  def compile(template, data) do
    Mustachex.render(template, data |> Map.from_struct())
  end

  @doc """
  Runs a bunch of tests to determine if the `template` is valid.
  """
  @spec valid?(String.t()) :: boolean
  def valid?(template) do
    try do
      structs = dummies()

      compiled_one = compile(template, Enum.at(structs, 0))
      compiled_two = compile(template, Enum.at(structs, 1))

      cond do
        compiled_one == compiled_two -> false
        String.contains?(compiled_one, ["{", "}"]) -> false
        String.contains?(compiled_two, ["{", "}"]) -> false
        true -> true
      end
    rescue
      FunctionClauseError -> false
    end
  end

  @spec dummies() :: list
  defp dummies() do
    [
      %Fotz.Format{
        year: 2018,
        month: 12,
        day: 31,
        hour: 23,
        minute: 59,
        second: 59,
        hash: "1a939412f73c3b056c56cacc99dd8cf7",
        smallhash: "1a93",
        city: "London",
        state: "England",
        country: "UK",
        camera: "Unknown",
        ext: "jpg",
        original: "DSC0001"
      },
      %Fotz.Format{
        year: 2019,
        month: 12,
        day: 31,
        hour: 23,
        minute: 59,
        second: 59,
        hash: "a52b4684cdd8dc21b551b81fe8134616",
        smallhash: "a52b",
        city: "London",
        state: "England",
        country: "UK",
        camera: nil,
        ext: "jpg",
        original: "DSC0002"
      }
    ]
  end
end
