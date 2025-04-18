
image:
	@${PWD}/bin/build_image.sh

expected:
	@${PWD}/bin/make_expected.sh

tests:
	@${PWD}/test/run_tests.sh

demo:
	@${PWD}/bin/run_demo.sh
