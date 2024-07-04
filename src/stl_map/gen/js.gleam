import esgleam

pub fn main() -> Nil {
  gen()
}

pub fn gen() -> Nil {
  let _ =
    esgleam.new("./generated_assets/js")
    |> esgleam.entry("stl_map/frontend/index2.gleam")
    |> esgleam.minify(True)
    |> esgleam.platform(esgleam.Browser)
    |> esgleam.target("es2022")
    |> esgleam.raw("--sourcemap")
    |> esgleam.bundle()

  Nil
}
