![github workflow](https://github.com/thiagoesteves/xfp_elixir/workflows/Elixir%20CI/badge.svg)
[![Build Status](https://secure.travis-ci.org/thiagoesteves/xfp_elixir.svg?branch=main)](http://travis-ci.org/thiagoesteves/xfp_elixir)
[![Coverage Status](https://coveralls.io/repos/github/thiagoesteves/xfp_elixir/badge.svg?branch=main)](https://coveralls.io/github/thiagoesteves/xfp_elixir?branch=main)
[![Erlant/OTP Release](https://img.shields.io/badge/Erlang-OTP--23.0-green.svg)](https://github.com/erlang/otp/releases/tag/OTP-23.0)

# The XFP application #

__Authors:__ Thiago Esteves ([`thiagocalori@gmail.com`](thiagocalori@gmail.com)).

## Note ##

The XFP application is dependent on GPROC library (Erlang) and the low level functions implemented at c_src/xfp_driver.c are just for test purposes (stubbed) and must be replace for the real accessors.

## Introduction ##

The XFP is a transceiver for high-speed computer network and telecommunication links that use optical fiber. It is largely used in telecommunications equipment and the code here is an example of how Erlang language can be used to handle eletronic devices with a wrapper to the basic fucntions (i2c, uart, spi, etc).

The driver is using the polling format to read the presence pin every 1 second which means that it will take up to 1 second to detect any changes. Once the device is inserted, all the static information is read and saved in its state.

### Compiling and Running ###

To compile and run for your machine just call the following command in the CLI:

```bash
$ iex -S mix
```

### Use case: Creating XFP devices ###

The user can create as many device as needed (the stub supports only 20, but with the real hardware there is no limitation):

```elixir
iex(1)> Xfp.Sup.create_xfp 0
{:ok, #PID<0.258.0>}
iex(2)> Xfp.get_temperature 0
{:ok, 64.0234375}
iex(3)> Xfp.get_state 0
%{
  aux_monitoring: 255,
  cdr_sup: 0,
  data_code: 'DATACODE',
  diagnostic: 255,
  enhanced: 85,
  identifier: 6,
  inst: 0,
  name: :"Xfp:0",
  part_number: 'VENDOR PARTNUMBE',
  present: true,
  revision: '01',
  vendor_name: 'VENDOR NAME  XFP',
  vendor_oui: 2097152,
  vendor_serial: 'VENDOR SERIALNUM',
  wavelength: 1131.5
}
iex(4)> Xfp.get_laser_state
{:ok, 1}
iex(5)> Xfp.Sup.remove_xfp 0 
:ok
```

### Stub: Emulating Insertion/Removal of the XFP ###

In order to test the capture of the insertion or the removal of the device you can write in the presence pin to simulate this condition as the example below:

```elixir
iex(1)> Xfp.Sup.create_xfp
{:ok, #PID<0.208.0>}
iex(2)> Xfp.get_state
%{
  aux_monitoring: 255,
  cdr_sup: 0,
  data_code: 'DATACODE',
  diagnostic: 255,
  enhanced: 85,
  identifier: 6,
  inst: 0,
  name: :"Xfp:0",
  part_number: 'VENDOR PARTNUMBE',
  present: true,
  revision: '01',
  vendor_name: 'VENDOR NAME  XFP',
  vendor_oui: 2097152,
  vendor_serial: 'VENDOR SERIALNUM',
  wavelength: 1131.5
}
iex(3)> Xfp.Driver.write_pin(0,2,1)
{:ok, 0}
iex(4)> Xfp.get_state              
%{inst: 0, name: :"Xfp:0", present: false}
```
### Supervisor tree ###

The supervisor tree of all XFP's created can be easily viewed with the observer, try the sequence of commands below and have a look at the Applications->xfp.

```elixir
iex(1)> Xfp.Sup.create_xfp 0
{:ok, #PID<0.208.0>}
iex(2)> Xfp.Sup.create_xfp 1
{:ok, #PID<0.210.0>}
iex(3)> Xfp.Sup.create_xfp 2
{:ok, #PID<0.212.0>}
iex(4)> Xfp.Sup.create_xfp 3
{:ok, #PID<0.214.0>}
iex(5)> Xfp.Sup.create_xfp 4
{:ok, #PID<0.216.0>}
iex(6)> Xfp.Sup.create_xfp 5
{:ok, #PID<0.218.0>}
iex(7)> :observer.start()
:ok
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xfp_app` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xfp_app, "~> 0.1.0"}
  ]
end
```
### Erlang Code References ###
```
http://erlang.org/doc/tutorial/c_port.html  
http://erlang.org/doc/reference_manual/ports.html
```
### Elixir Code References ###
```
https://elixir-lang.org/
https://tonyc.github.io/posts/managing-external-commands-in-elixir-with-ports/  
https://cultivatehq.com/posts/communicating-with-c-from-elixir-using-ports/
```
### XFP References ###
```
https://www.gigalight.com/downloads/standards/INF-8077i.pdf  
https://en.wikipedia.org/wiki/XFP_transceiver
```

