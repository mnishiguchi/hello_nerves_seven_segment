defmodule HelloNervesSevenSegment.SPI do
  @type spi :: %{ref: reference, bus_name: bus_name}
  @type bus_name :: binary | charlist
  @type spi_option :: Circuits.SPI.spi_option()

  @callback open(bus_name, [spi_option]) ::
              {:ok, spi} | {:error, any}

  @callback transfer(spi, iodata) :: :ok
end

defmodule HelloNervesSevenSegment.SPI.Target do
  @behaviour HelloNervesSevenSegment.SPI

  @impl true
  def open(bus_name, opts \\ []) do
    with {:ok, ref} <- Circuits.SPI.open(bus_name, opts) do
      spi = %{ref: ref, bus_name: bus_name}

      {:ok, spi}
    end
  end

  @impl true
  def transfer(spi, data) do
    Circuits.SPI.transfer!(spi.ref, data)
    :ok
  end
end

defmodule HelloNervesSevenSegment.SPI.Host do
  @behaviour HelloNervesSevenSegment.SPI

  @impl true
  def open(bus_name, _opts \\ []) do
    {:ok, %{ref: make_ref(), bus_name: bus_name}}
  end

  @impl true
  def transfer(_spi, _data) do
    :ok
  end
end
