import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import gleam/string
import gleam/yielder
import stdin

pub fn main() {
  let input =
    stdin.read_lines()
    |> yielder.to_list
    |> string.join("\n")

  case json.parse(from: input, using: decode.dynamic) {
    Error(_) -> io.println("Error happened while parsing")
    Ok(value) -> render(value)
  }
}

fn render(root: Dynamic) -> Nil {
  let model =
    root
    |> decode_model
    |> result.unwrap("Claude")

  let pct =
    root
    |> decode_used_percentage
    |> result.unwrap(0)

  let usg =
    root
    |> decode_used_usd_cost
    |> result.unwrap(0.0)

  let input_tokens =
    root
    |> decode_input_tokens
    |> result.unwrap(0)

  let output_tokens =
    root
    |> decode_output_tokens
    |> result.unwrap(0)

  io.println(
    "🤖 "
    <> model
    <> " | 🧠 "
    <> int.to_string(pct)
    <> "% context"
    <> " | 🔥 \u{eab4} "
    <> format_tokens(input_tokens)
    <> " \u{eab7} "
    <> format_tokens(output_tokens)
    <> " | 💸 $"
    <> format_cost(usg),
  )
}

fn decode_model(root: Dynamic) -> Result(String, List(decode.DecodeError)) {
  let model_decoder = decode.at(["model", "display_name"], decode.string)

  decode.run(root, model_decoder)
}

fn decode_used_percentage(
  root: Dynamic,
) -> Result(Int, List(decode.DecodeError)) {
  let pct_decoder = {
    use value <- decode.then(decode.at(
      ["context_window", "used_percentage"],
      decode.dynamic,
    ))
    int_or_float(value)
  }

  decode.run(root, pct_decoder)
}

fn decode_used_usd_cost(
  root: Dynamic,
) -> Result(Float, List(decode.DecodeError)) {
  let cost_decoder = decode.at(["cost", "total_cost_usd"], decode.float)

  decode.run(root, cost_decoder)
}

fn decode_input_tokens(root: Dynamic) -> Result(Int, List(decode.DecodeError)) {
  let tokens_decoder =
    decode.at(["context_window", "current_usage", "input_tokens"], decode.int)

  decode.run(root, tokens_decoder)
}

fn decode_output_tokens(root: Dynamic) -> Result(Int, List(decode.DecodeError)) {
  let tokens_decoder =
    decode.at(["context_window", "current_usage", "output_tokens"], decode.int)

  decode.run(root, tokens_decoder)
}

fn int_or_float(v: Dynamic) -> decode.Decoder(Int) {
  case decode.run(v, decode.int) {
    Ok(i) -> decode.success(i)
    Error(_) ->
      case decode.run(v, decode.float) {
        Ok(f) -> decode.success(float.round(f))
        Error(_) -> decode.failure(0, "int or float")
      }
  }
}

fn format_cost(cost: Float) -> String {
  let rounded = float.round(cost *. 1000.0) |> int.to_float
  let formatted = rounded /. 1000.0
  float.to_string(formatted)
}

fn format_tokens(tokens: Int) -> String {
  case tokens {
    t if t >= 1_000_000 -> {
      let millions = int.to_float(t) /. 1_000_000.0
      let rounded = float.round(millions *. 10.0) |> int.to_float
      let formatted = rounded /. 10.0
      float.to_string(formatted) <> "M"
    }
    t if t >= 1000 -> {
      let thousands = int.to_float(t) /. 1000.0
      let rounded = float.round(thousands *. 10.0) |> int.to_float
      let formatted = rounded /. 10.0
      float.to_string(formatted) <> "k"
    }
    t -> int.to_string(t)
  }
}
