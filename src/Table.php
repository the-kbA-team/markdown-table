<?php

namespace kbATeam\MarkdownTable;

use RuntimeException;

/**
 * Class kbATeam\MarkdownTable\Table
 *
 * Generates a markdown table for a fixed number of columns from an array of rows.
 *
 * @category library
 * @package  kbATeam\MarkdownTable
 * @license  MIT
 * @author   gregor-j
 */
class Table
{
    /**
     * @var \kbATeam\MarkdownTable\Column[]
     */
    private $columns;

    /**
     * @var int The number of columns.
     */
    private $column_count;

    /**
     * @var string Markdown cell separator string.
     */
    private static $separator = ' | ';

    /**
     * Table constructor.
     * It is possible to define the columns using an array like this:
     * ['first', 'next', 'last']
     * @param array $keys Optional an array of column names. Default: []
     */
    public function __construct(array $keys = [])
    {
        $this->clearColumns();
        foreach ($keys as $key) {
            $this->addColumn($key, new Column($key));
        }
    }

    /**
     * Remove all defined columns from this table.
     * @return \kbATeam\MarkdownTable\Table $this
     */
    public function clearColumns(): Table
    {
        $this->columns = [];
        $this->column_count = 0;
        return $this;
    }

    /**
     * Adds a column to the table.
     * @param string|int Unique name/id for the column position.
     * @param \kbATeam\MarkdownTable\Column $column
     * @return \kbATeam\MarkdownTable\Table $this
     */
    public function addColumn($pos, Column $column): Table
    {
        if (!array_key_exists($pos, $this->columns)) {
            //Counts the columns up as they are added.
            $this->column_count++;
        }
        $this->columns[$pos] = $column;

        return $this;
    }

    /**
     * Return the column on the requested position.
     * @param string|int $pos The column position to fetch.
     * @return \kbATeam\MarkdownTable\Column
     * @throws \RuntimeException in case the given position does not exist.
     */
    public function getColumn($pos): Column
    {
        if (!array_key_exists($pos, $this->columns)) {
            throw new RuntimeException(sprintf('Column position %s does not exist!', $pos));
        }

        return $this->columns[$pos];
    }

    /**
     * Determine whether this table has columns.
     * @return bool
     */
    public function hasColumns(): bool
    {
        return $this->column_count > 0;
    }

    /**
     * Remove a column from the table.
     * @param string|int $pos The column position to remove.
     * @return \kbATeam\MarkdownTable\Table $this
     */
    public function dropColumn($pos): Table
    {
        if (array_key_exists($pos, $this->columns)) {
            $this->column_count--;
        }
        unset($this->columns[$pos]);
        return $this;
    }

    /**
     * Reset the length of each column to either three or the title length.
     */
    private function resetColumnLengths()
    {
        foreach ($this->columns as $column) {
            $column->resetMaxLength();
        }
    }

    /**
     * Generate a markdown table from the defined columns and their rows.
     * @param array $rows Rows of the markdown table.
     * @return \Generator generates a string for each row including the headers.
     * @throws \RuntimeException in case no columns are defined, or in case the rows
     *                           parameter is not an array of arrays.
     */
    public function generate(array $rows)
    {
        if (!$this->hasColumns()) {
            throw new RuntimeException('No columns defined.');
        }

        $this->resetColumnLengths();

        /**
         * Process each row, clean each cells string and determine the maximum
         * length of each cell based on the cleaned string. Missing cells in a row
         * get replaced by an empty string.
         */
        foreach ($rows as $id => $row) {
            /**
             * Detect malformed rows array.
             */
            if (!is_array($row)) {
                throw new RuntimeException('Rows need to be an array of arrays.');
            }
            /**
             * Get the content of each defined column from the row.
             */
            foreach ($this->columns as $pos => $column) {
                //Set an empty string for each expected column not defined in the row.
                $cell = '';
                if (array_key_exists($pos, $row)) {
                    $cell = filter_var(
                        (string)$row[$pos],
                        FILTER_SANITIZE_STRING,
                        FILTER_FLAG_STRIP_BACKTICK | FILTER_FLAG_STRIP_LOW
                    );
                    $column->setMaxLength(mb_strlen($cell));
                }
                $row[$pos] = $cell;
            }
            $rows[$id] = $row;
        }

        /**
         * yield table header
         */
        $result = [];
        foreach ($this->columns as $column) {
            $result[] = $column->createHeader();
        }
        yield implode(self::$separator, $result);
        unset($result);

        /**
         * yield table header separator
         */
        $result = [];
        foreach ($this->columns as $column) {
            $result[] = $column->createHeaderSeparator();
        }
        yield implode(self::$separator, $result);
        unset($result);

        /**
         * yield each row
         */
        foreach ($rows as $row) {
            $result = [];
            foreach ($this->columns as $pos => $column) {
                $result[] = $column->createCell($row[$pos]);
            }
            yield implode(self::$separator, $result);
            unset($result);
        }
    }

    /**
     * Get a markdown table as string with line breaks.
     * @param array $rows The rows to create a table from.
     * @return string The markdown table.
     * @throws \RuntimeException in case no columns are defined, or in case the rows
     *                           parameter is not an array of arrays.
     */
    public function getString(array $rows): string
    {
        $result = '';
        foreach ($this->generate($rows) as $row) {
            $result .= sprintf('%s%s', $row, PHP_EOL);
        }
        return $result;
    }
}
