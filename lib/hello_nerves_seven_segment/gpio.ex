defmodule HelloNervesSevenSegment.GPIO do
  @type gpio :: %{ref: reference, pin_number: pin_number}
  @type pin_direction :: Circuits.GPIO.pin_direction()
  @type pin_number :: Circuits.GPIO.pin_number()
  @type open_option :: Circuits.GPIO.open_option()
  @type value :: Circuits.GPIO.value()

  @callback open(pin_number, pin_direction, [open_option]) ::
              {:ok, gpio} | {:error, any}

  @callback write(gpio, value) :: :ok
end

defmodule HelloNervesSevenSegment.GPIO.Target do
  @behaviour HelloNervesSevenSegment.GPIO

  @impl true
  def open(pin_number, pin_direction, opts \\ []) do
    with {:ok, ref} <- Circuits.GPIO.open(pin_number, pin_direction, opts) do
      gpio = %{ref: ref, pin_number: pin_number}

      {:ok, gpio}
    end
  end

  @impl true
  def write(gpio, value) do
    Circuits.GPIO.write(gpio.ref, value)
  end
end

defmodule HelloNervesSevenSegment.GPIO.Host do
  @behaviour HelloNervesSevenSegment.GPIO

  @impl true
  def open(pin_number, _pin_direction, _opts \\ []) do
    {:ok, %{ref: make_ref(), pin_number: pin_number}}
  end

  @impl true
  def write(_gpio, _value) do
    :ok
  end
end
