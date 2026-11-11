# markdown-table

[![License: MIT][license-mit]](LICENSE)
[![PHP Composer & PHPUnit]][GitHub actions]

Create a [Markdown][markdown] table containing your data.

## Install

```
composer require kba-team/markdown-table
```

## Usage

A simple example:

```php
<?php
use kbATeam\MarkdownTable\Table;
use kbATeam\MarkdownTable\Column;
$data = [
  [
    'A' => 'markdown',
    'B' => 'is'
  ],
  [
    'A' => 'great',
    'B' => 'software',
  ]
];
$table = new Table();
$table->addColumn('A', new Column('Column A', Column::ALIGN_RIGHT));
$table->addColumn('B', new Column('another Column', Column::ALIGN_LEFT));
foreach ($table->generate($data) as $row) {
  printf('%s%s', $row, PHP_EOL);
}
```

Result:

```markdown
| Column A | another Column |
|---------:|:---------------|
| markdown | is             |
|    great | software       |
```

## Testing

Development requires Docker, Make, and a host PHP version matching the selected
version, with mbstring installed. Composer runs in Docker; `PHP_VERSION` selects
the dependency platform but does not change the host PHP executable.

```sh
make help
make install PHP_VERSION=8.3
make lint PHP_VERSION=8.3
make test PHP_VERSION=8.3
make validate
make audit
```

Install resolves dependencies without retaining `composer.lock`, using the
Composer cache in `~/.cache/composer`. It forwards proxy environment variables;
set `CA_CERT_FILE` to a PEM CA bundle if a custom certificate is needed.
Existing Composer configuration is preserved. To test the lowest compatible
dependencies, run:

```sh
make install PHP_VERSION=7.4 DEPENDENCIES_LOWEST=1
make test PHP_VERSION=7.4
```

Production supports PHP 7.1, but PHPUnit 8.5 requires a newer PHP version.
The 7.1 CI job installs production dependencies only, lints, and runs a rendering
smoke test; PHPUnit runs on 7.4 and 8.0–8.4. To reproduce the production
installation, use `make install PHP_VERSION=7.1 COMPOSER_NO_DEV=1` and
`php tests/smoke.php` with PHP 7.1. CI publishes Clover coverage from PHP 7.4
as an artifact; PHPUnit 8 cannot collect coverage on PHP 8. Run
`tests/test-make-install.sh` to check install cleanup and flags without Docker.

## [MIT License](LICENSE)

Copyright (c) 2018 the-kbA-team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[license-mit]: https://img.shields.io/badge/license-MIT-blue.svg
[PHP Composer & PHPUnit]: https://github.com/the-kbA-team/markdown-table/actions/workflows/php.yml/badge.svg
[GitHub actions]: https://github.com/the-kbA-team/markdown-table/actions/workflows/php.yml
[markdown]: https://daringfireball.net/projects/markdown/ "Markdown is a text-to-HTML conversion tool for web writers."
