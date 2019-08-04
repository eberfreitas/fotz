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
    :minutes,
    :seconds,
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
          year: integer | nil,
          month: integer | nil,
          day: integer | nil,
          hour: integer | nil,
          minutes: integer | nil,
          seconds: integer | nil,
          hash: String.t() | nil,
          smallhash: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          camera: String.t() | nil,
          ext: String.t() | nil,
          original: String.t() | nil
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
    structs = dummies()

    compiled_one = compile(template, Enum.at(structs, 0))
    compiled_two = compile(template, Enum.at(structs, 1))

    cond do
      compiled_one == compiled_two -> false
      String.contains?(compiled_one, ["{", "}"]) -> false
      String.contains?(compiled_two, ["{", "}"]) -> false
      true -> true
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
        minutes: 59,
        seconds: 59,
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
        minutes: 59,
        seconds: 59,
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
