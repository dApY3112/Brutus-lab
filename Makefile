.PHONY: setup vuln secured test test-secured verify stop clean-results

setup:
	./setup.sh

vuln:
	./run_vuln.sh

secured:
	./run_secured.sh

test:
	./exploit_test.sh

test-secured:
	./exploit_test.sh --secured

verify:
	./verify_lab.sh

stop:
	./stop_lab.sh

clean-results:
	find results -type f ! -name '.gitkeep' -delete

