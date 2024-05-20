deps_download:
	cd common && gleam deps download
	cd frontend && gleam deps download
	cd site_generator && gleam deps download

build:
	cd common && gleam build
	cd frontend && gleam build
	cd site_generator && gleam build

gen_site:
	cd site_generator && gleam run
	mkdir -p site && cp -r site_generator/priv/* site/

gen_js:
	mkdir -p site/js && cp frontend/index.js site/js/index.js

gen: gen_site gen_js

serve:
	python -m http.server -d site
