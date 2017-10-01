default: venv
dots=$(wildcard *.dot)
pngs=$(patsubst %.dot,%.png,$(dots))
venv: venv/bin/activate

venv/bin/activate: requirements.txt
	test -d venv || virtualenv -p python3 venv
	. venv/bin/activate; venv/bin/pip install -Ur requirements.txt
	touch venv/bin/activate

$(pngs): $(dots)
	dot -T png -o $@ $<

diagrams: $(pngs)
