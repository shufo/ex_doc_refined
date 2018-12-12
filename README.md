# ExDocRefined

A refined document viewer for Elixir and Phoenix

## Overview

<a href="https://i.imgur.com/VKfg3yz.gif"><img src="https://i.imgur.com/VKfg3yz.gif"></a>

### Features

- :fast_forward: Dynamic Document Update without `mix docs`
- :rainbow: Syntax Highlight
- :bird: Embeddable to Phoenix (1.3 & 1.4 supported)
- :page_facing_up: Interactively Execute Function on document

<img src="https://i.imgur.com/lC7NHvZ.png" width="700 c">

## Installation

`mix.exs`

```elixir
def deps do
  [
    {:ex_doc_refined, "~> 0.1.0", only: [:dev]}
  ]
end
```

Add it to applications (if `application` block exists)

```elixir
def application do
  [applications: [:ex_doc_refined]]
end
```

start your application

```bash
$ ➜ iex -S mix
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe]

05:51:25.379 [info]  ExDocRefined started listening on http://localhost:5600
Interactive Elixir (1.7.4) - press Ctrl+C to exit (type h() ENTER for help)
```

then open http://localhost:5600

## Configuration

### Phoenix Integration

Basically ExDoc Refined can works as standalone elixir app.

But you can also integrate ExDoc Refined with Phoenix as well.

1. Add route for ExDocRefined

`router.ex`

```elixir
scope "/" do
  pipe_through(:browser)
  get("/", MyAppWeb.PageController, :index)
end

# Added route for docs
forward("/docs", ExDocRefined.Router)
```

### Cowboy

:exclamation: Phoenix depends [Cowboy](https://github.com/ninenines/cowboy) HTTP server and Cowboy 2.0 had breaking change, so you must change configuration according to Phoenix and Cowboy version.

#### For Phoenix 1.3 users

|  phoenix |   cowboy |
| -------: | -------: |
| `~> 1.3` | `~> 1.0` |

Add socket endpoint to your `endpoint.ex`.

`endpoint.ex`

```elixir
socket("/docs", ExDocRefined.PhoenixSocket)
```

:exclamation:️ This path **MUST** same with the path you defined in router.

#### For Phoenix 1.4 & Cowboy 1.0 users

|  phoenix |   cowboy |
| -------: | -------: |
| `~> 1.4` | `~> 1.0` |

This case is for if you have upgraded Phoenix 1.3 to 1.4 and still using cowboy 1.0

`endpoint.ex`

```elixir
socket "/docs", ExDocRefined.PhoenixSocket,
    websocket: true,
    longpoll: false
```

#### For Phoenix 1.4 & Cowboy 2.0 users

|  phoenix |   cowboy |
| -------: | -------: |
| `~> 1.4` | `~> 2.0` |

`config/config.exs`

Add dispatch option for cowboy.

Please **CHANGE** app name to your app name. (`:my_app`, `MyAppWeb`)

```elixir
config :my_app, MyAppWeb.Endpoint,
  http: [
    dispatch: [
      {:_,
       [
         {"/docs/websocket", ExDocRefined.WebSocketHandler, []},
         {:_, Phoenix.Endpoint.Cowboy2Handler, {MyAppWeb.Endpoint, []}}
       ]}
    ]
  ]
```

then start the phoenix and open http://localhost:4000/docs in your browser to view docs

<img src="https://i.imgur.com/hobcoBb.png">

### Standalone mode

If you are using phoenix integration and standalone server is not necessary, you can disable standalone server. Defaults to `true`.

`config/config.exs`

```elixir
config :ex_doc_refined, standalone: false
```

### Standalone server port

If you want to change standalone server port, you can change by specify `port`. Defaults to `5600`.

`config/config.exs`

```elixir
config :ex_doc_refined, port: 4002
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## Test

1. Clone this repo
2. `mix deps.get && iex -S mix`
3. Open another window to run nuxt.js
4. `cd src && npm install && npm run dev`

## TODO

- [ ] UI improvement
- [ ] Use ex_doc's function to follow the change of elixir official release
- [ ] Provide option to disable function runner on docs

## License

MIT
