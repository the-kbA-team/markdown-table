# Runtime and test-tool support

This library retains PHP 7.1 production support while PHPUnit 8.5 requires PHP 7.2 or newer. CI therefore installs production dependencies, lints and smoke-tests on 7.1, and runs PHPUnit on 7.4 and PHP 8.0–8.4 instead of raising the runtime minimum or downgrading the test suite. PHPUnit 8 cannot collect coverage on PHP 8, so the 7.4 job publishes the Clover artifact.

As a library, we do not retain a Composer lockfile: dependencies are resolved for each selected PHP version, with a separate lowest-dependency check. Consumers resolve their own dependency versions.
