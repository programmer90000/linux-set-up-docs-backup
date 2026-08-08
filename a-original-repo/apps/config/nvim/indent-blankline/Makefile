ifndef VERBOSE
.SILENT:
endif

test: dependencies
	@echo "Running indent-blankline tests..."
	timeout 300 nvim -e \
		--headless \
		--noplugin \
		-u specs/spec.lua \
		-c "PlenaryBustedDirectory specs/features {minimal_init = 'specs/spec.lua'}"

luacheck:
	luacheck .

lua-language-server: dependencies
	rm -rf .ci/lua-language-server-log
	lua-language-server --configpath .luarc.$(version).json --logpath .ci/lua-language-server-log --check .
	@if jq -e 'if . | length > 0 then true else false end' .ci/lua-language-server-log/check.json > /dev/null; then \
		cat .ci/lua-language-server-log/check.json; \
		exit 1; \
	fi
