import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/io
import gleam/json
import gleam/list
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

  let dir =
    root
    |> decode_current_dir
    |> result.unwrap("")

  let folder = basename(dir)

  let pct =
    root
    |> decode_used_percentage
    |> result.unwrap(0)

  let usg =
    root
    |> decode_used_usd_cost
    |> result.unwrap(0.0)

  io.println(
    "🤖 "
    <> model
    <> " | 📁 "
    <> folder
    <> " | 🧠 "
    <> int.to_string(pct)
    <> "% context"
    <> " | 💸 $"
    <> float.to_string(usg),
  )
}

fn decode_model(root: Dynamic) -> Result(String, List(decode.DecodeError)) {
  let model_decoder = decode.at(["model", "display_name"], decode.string)

  decode.run(root, model_decoder)
}

fn decode_current_dir(root: Dynamic) -> Result(String, List(decode.DecodeError)) {
  let dir_decoder = decode.at(["workspace", "current_dir"], decode.string)

  decode.run(root, dir_decoder)
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

fn basename(path: String) -> String {
  let trimmed = case string.ends_with(path, "/") {
    True -> string.drop_end(path, 1)
    False -> path
  }

  trimmed
  |> string.split("/")
  |> list_last("")
}

fn list_last(items: List(String), default: String) -> String {
  case items {
    [] -> default
    _ ->
      items
      |> list.reverse
      |> list.first
      |> result.unwrap(default)
  }
}
