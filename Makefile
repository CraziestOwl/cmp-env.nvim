.PHONY: test gen_tests

gen_tests:
	python3 ./tests/gen_env_file.py
test:
	nvim --headless  -u tests/minimal.vim -c "PlenaryBustedDirectory tests/cmp_env {minimal_init = 'tests/minimal.vim', sequential = true}"
