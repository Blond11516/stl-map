import gleam/javascript/promise.{type Promise}
import glen
import glen/status

pub fn main() {
  glen.serve(8000, handle_req)
}

fn handle_req(req: glen.Request) -> Promise(glen.Response) {
  use <- glen.static(req, "", "./public/")

  status.ok
  |> glen.response()
  |> promise.resolve()
}
