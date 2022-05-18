# markdown-table

[![License: MIT][license-mit]](LICENSE)
[![PHP Composer & PHPUnit]][GitHub actions]
[![Maintainability][maintainability-badge]][maintainability]
[![Test Coverage][coverage-badge]][coverage]

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
 Column A | another Column 
 -------: | :------------- 
 markdown | is             
    great | software       
```

## Testing

Get [composer][composer], and install the dependencies.

```sh
composer install
```

Call phpunit to run the tests available. You'll see not only the results of the tests but the code coverage too.

```sh
vendor/bin/phpunit
```

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
[maintainability-badge]: https://api.codeclimate.com/v1/badges/ef2542e986fda45f718f/maintainability
[maintainability]: https://codeclimate.com/github/the-kbA-team/markdown-table/maintainability
[coverage-badge]: https://api.codeclimate.com/v1/badges/ef2542e986fda45f718f/test_coverage
[coverage]: https://codeclimate.com/github/the-kbA-team/markdown-table/test_coverage
[markdown]: https://daringfireball.net/projects/markdown/ "Markdown is a text-to-HTML conversion tool for web writers."
[composer]: https://getcomposer.org/ "Dependency Manager for PHP"
