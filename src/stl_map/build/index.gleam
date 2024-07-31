import gleam/int
import gleam/list
import gleam/option.{type Option, None}
import gleam/string
import lustre/attribute
import lustre/element/html.{html}
import lustre/ssg
import stl_map/gtfs
import stl_map/route.{type Route}
import stl_map/time_of_day

pub fn main() -> Nil {
  build(None)
}

pub fn build(routes: Option(List(Route))) -> Nil {
  let routes = option.lazy_unwrap(routes, gtfs.load_routes)

  let index_html = html([], [head(), body(routes)])

  let _ =
    ssg.new("./dist/index")
    |> ssg.add_static_route("/", index_html)
    |> ssg.build()

  Nil
}

fn head() {
  html.head([], [
    html.meta([attribute.attribute("charset", "utf-8")]),
    html.title([], "Carte STL"),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href("css/leaflet/leaflet.css"),
    ]),
    html.link([attribute.rel("stylesheet"), attribute.href("css/reset.css")]),
    html.link([attribute.rel("stylesheet"), attribute.href("css/index.css")]),
    html.script([attribute.type_("module"), attribute.src("js/index.mjs")], ""),
  ])
}

fn body(routes: List(Route)) {
  let assert Ok(last_departure_time) =
    routes
    |> list.flat_map(fn(route) { route.trips })
    |> list.flat_map(fn(trip) { trip.stops })
    |> list.map(fn(stop) { stop.departure_time })
    |> list.sort(time_of_day.compare)
    |> list.last()

  html.body([], [
    html.form([attribute.id("routes-form")], [
      html.div([attribute.style([#("width", "250px"), #("flex-shrink", "0")])], [
        html.label([], [
          html.input([
            attribute.type_("range"),
            attribute.name("startAfter"),
            attribute.attribute("step", "10"),
            attribute.min("0"),
            attribute.max(
              last_departure_time
              |> time_of_day.as_minutes()
              |> int.to_string(),
            ),
          ]),
          html.div([], [
            html.text("Départ après: "),
            html.span([attribute.id("startTimePreview")], []),
          ]),
        ]),
        html.div(
          [
            attribute.style([
              #("display", "flex"),
              #("flex-direction", "row"),
              #("gap", "4px"),
            ]),
          ],
          [
            html.fieldset([], [
              html.legend([], [html.text("Direction:")]),
              html.label([], [
                html.input([
                  attribute.type_("radio"),
                  attribute.name("direction"),
                  attribute.value("0"),
                  attribute.checked(True),
                ]),
                html.text("0"),
              ]),
              html.label([], [
                html.input([
                  attribute.type_("radio"),
                  attribute.name("direction"),
                  attribute.value("1"),
                ]),
                html.text("1"),
              ]),
            ]),
            html.div([attribute.style([#("padding-top", "15px")])], [
              html.div(
                [
                  attribute.style([
                    #("display", "flex"),
                    #("flex-direction", "row"),
                    #("align-items", "center"),
                  ]),
                ],
                [
                  html.img([
                    attribute.src("images/start_circle.svg"),
                    attribute.class("legend-image"),
                  ]),
                  html.text("Début de la route"),
                ],
              ),
              html.div(
                [
                  attribute.style([
                    #("display", "flex"),
                    #("flex-direction", "row"),
                    #("align-items", "center"),
                  ]),
                ],
                [
                  html.img([
                    attribute.src("images/end_circle.svg"),
                    attribute.class("legend-image"),
                  ]),
                  html.text("Arrêt"),
                ],
              ),
            ]),
          ],
        ),
      ]),
      html.div(
        [],
        routes
          |> list.sort(fn(left, right) { string.compare(left.id, right.id) })
          |> list.map(fn(route) {
            html.label([], [
              html.text(route.id),
              html.input([attribute.type_("checkbox"), attribute.name(route.id)]),
            ])
          }),
      ),
    ]),
    html.div([attribute.id("map")], []),
  ])
}
