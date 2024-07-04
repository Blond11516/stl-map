SITE_DIR := "site"

default: build

create_site_dir:
	mkdir -p {{SITE_DIR}}

copy_index: create_site_dir
	cp dist/index/index.html {{SITE_DIR}}/index.html

build_index: && copy_index
	gleam run -m stl_map/build/index

copy_routes: create_site_dir
	cp dist/routes/* {{SITE_DIR}}

build_routes: && copy_routes
	gleam run -m stl_map/build/routes

copy_js: create_site_dir
	mkdir -p {{SITE_DIR}}/js
	cp dist/js/index2.js* {{SITE_DIR}}/js/

build_js: && copy_js
	gleam run -m stl_map/build/js

copy_static_assets:
	cp -r static_assets/* {{SITE_DIR}}

build: && copy_index copy_routes copy_static_assets copy_js
	rm -rf {{SITE_DIR}}
	gleam run -m stl_map/build/all

serve:
	python -m http.server -d {{SITE_DIR}}
