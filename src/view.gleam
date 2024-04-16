import lustre/attribute
import lustre/element/html.{html}
import route.{type Route}

pub fn view(routes: List(Route)) {
  let assert [route, ..] = routes
  html([], [head(), body()])
}

fn head() {
  html.head([], [
    html.title([], "Carte STL"),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href("https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"),
      attribute.attribute(
        "integrity",
        "sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=",
      ),
      attribute.attribute("crossorigin", ""),
    ]),
    html.script(
      [
        attribute.src("https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"),
        attribute.attribute(
          "integrity",
          "sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=",
        ),
        attribute.attribute("crossorigin", ""),
      ],
      "",
    ),
    html.link([attribute.rel("stylesheet"), attribute.href("css/reset.css")]),
    html.link([attribute.rel("stylesheet"), attribute.href("css/index.css")]),
    html.script([attribute.type_("module"), attribute.src("js/index.js")], ""),
  ])
}

fn body() {
  html.body([], [html.div([attribute.id("map")], [])])
}
