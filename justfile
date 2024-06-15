gen_site:
	gleam run

gen_js:
	gleam build
	mkdir -p site/js
	rsync --relative --recursive --prune-empty-dirs --include="*/" --include="*.mjs" --exclude="*"  build/dev/javascript/./ site/js

gen: && gen_site gen_js
	rm -rf site

serve:
	python -m http.server -d site
