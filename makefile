STACK_GHC = 
HS_FILES = $(wildcard src*/*.hs)

format:
	@echo "Checking formatting in labs directory..."
	@for %%f in ($(HS_FILES)) do ( \
		echo Checking %%f... && \
		ormolu --mode inplace %%f || exit 1 \
	)

build: src/Main.hs src/Parser.hs src/Markdown.hs src/Types.hs
	stack ghc -- src/Main.hs src/Parser.hs src/Markdown.hs src/Types.hs -hidir build -O3 -odir build -o runnable/parser

run: build
	./runnable/parser ./test/simple_features.md ./test/output.html

run-c: build
	./runnable/parser -c

.PHONY: format build run
