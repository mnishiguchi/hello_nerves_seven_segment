import Config

# Add configuration that is only needed when running on the host here.
config :hello_nerves_seven_segment, spi_mod: HelloNervesSevenSegment.SPI.Host
config :hello_nerves_seven_segment, gpio_mod: HelloNervesSevenSegment.GPIO.Host
