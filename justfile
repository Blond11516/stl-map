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
	mkdir -p site
	cp -r site_generator/priv/* site/

gen_js:
	cd frontend && gleam build
	mkdir -p site/js
	rsync --relative --recursive --prune-empty-dirs --include="*/" --include="*.mjs" --exclude="*"  frontend/build/dev/javascript/./ site/js

gen: && gen_site gen_js
	rm -rf site

serve:
	python -m http.server -d site
