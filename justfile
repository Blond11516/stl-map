SITE_DIR := "site"

create_site_dir:
	mkdir -p {{SITE_DIR}}

copy_index: create_site_dir
	cp generated_assets/index/index.html {{SITE_DIR}}/index.html

gen_index: && copy_index
	gleam run -m stl_map/gen/index

copy_routes: create_site_dir
	cp generated_assets/routes/* {{SITE_DIR}}

gen_routes: && copy_routes
	gleam run -m stl_map/gen/routes

copy_js: create_site_dir
	mkdir -p {{SITE_DIR}}/js
	cp generated_assets/js/index2.js* {{SITE_DIR}}/js/

gen_js: && copy_js
	gleam run -m stl_map/gen/js

copy_static_assets:
	cp -r static_assets/* {{SITE_DIR}}

gen: && copy_index copy_routes copy_static_assets copy_js
	rm -rf {{SITE_DIR}}
	gleam run -m stl_map/gen/all

serve:
	python -m http.server -d {{SITE_DIR}}
