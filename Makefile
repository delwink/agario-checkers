OUT=agario-checkers.love
DATA=README COPYING
SOURCES=main.lua

all: zip

zip:
	zip -u $(OUT) $(DATA) $(SOURCES)
