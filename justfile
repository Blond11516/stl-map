create_site_dir:
	mkdir -p site

copy_index: create_site_dir
	cp generated_assets/index/index.html site/index.html

gen_index: && copy_index
	gleam run -m stl_map/gen/index

copy_routes: create_site_dir
	cp generated_assets/routes/* site

gen_routes: && copy_routes
	gleam run -m stl_map/gen/routes

copy_static_assets:
	cp -r static_assets/* site

gen_js:
	gleam build
	mkdir -p site/js
	rsync --relative --recursive --prune-empty-dirs --include="*/" --include="*.mjs" --exclude="*"  build/dev/javascript/./ site/js

gen: && gen_js copy_index copy_routes copy_static_assets
	rm -rf site
	gleam run -m stl_map/gen/all

serve:
	python -m http.server -d site
