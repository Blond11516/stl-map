PUBLIC_DIR := "public"

default: build

create_public_dir:
	mkdir -p {{PUBLIC_DIR}}

copy_index: create_public_dir
	cp dist/index/index.html {{PUBLIC_DIR}}/index.html

build_index: && copy_index
	gleam run -m stl_map/build/index

copy_routes: create_public_dir
	mkdir -p {{PUBLIC_DIR}}/routes
	cp dist/routes/* {{PUBLIC_DIR}}/routes

build_routes: && copy_routes
	gleam run -m stl_map/build/routes

copy_js: create_public_dir
	mkdir -p {{PUBLIC_DIR}}/js
	cp dist/js/index2.js* {{PUBLIC_DIR}}/js/

build_js: && copy_js
	gleam run -m stl_map/build/js

dev_js: && copy_static_assets
	rm -rf {{PUBLIC_DIR}}/js
	mkdir -p {{PUBLIC_DIR}}/js
	gleam build
	cd build/dev/javascript && rsync -r -f '+ *.mjs' -f '+ *.js' -f '+ **/' -f '- *' --prune-empty-dirs . ../../../{{PUBLIC_DIR}}/js
	echo 'export * from "./stl_map/stl_map/frontend/index2.mjs"' > {{PUBLIC_DIR}}/js/index2.js

copy_static_assets: create_public_dir
	cp -r static_assets/* {{PUBLIC_DIR}}

build: && copy_index copy_routes copy_static_assets copy_js
	rm -rf {{PUBLIC_DIR}}
	gleam run -m stl_map/build/all

serve:
	gleam run -m stl_map/serve
