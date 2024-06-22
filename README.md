# spreadsheet-read-simple-perl

Perl module `Spreadsheet::Read::Simple` for simple parsing of spreadsheets


## Synopsis

```perl
# Include module
use Spreadsheet::Read::Simple;

# Read spreadsheet
my $book = ReadDataSimple($file);
```


## Description

This module combines the capabilities of the modules `Spreadsheet::Read`
and `DataExtract::FixedWidth` in order to parse both, conventional
spreadsheets and text files with data in fixed width columns.

The latter is being achieved by converting the text file with fixed
width columns to a temporary CSV spreadsheet and parsing this file using
the method `ReadData` provided by `Spreadsheet::Read`.

## Export

The following symbols are exported.

+ `&ReadDataSimple`

## Subroutines

+ **ReadDataSimple**( *source* [, _option_ => _value_ [, ... ]])`

  The subroutine `ReadDataSimple` is a wrapper for the subroutine `ReadData`.
  It receives a mandatory argument _source_ which can be the name of file or
  a file handle. If it is a file, several checks are being performed in order
  to identify text files with fixed-width columns. If these checks are positive
  the text file is converted to an temporary CSV file and afterwards parsed
  using the ordinary subroutine `ReadData`. The subroutine `ReadDataSimple`
  may receive additional arguments in key-value-syntax. Refer to the
  documentation of `Spreadsheet::Read` for details.  The following options
  are recognized:

  + **sep** => _char_

    The option **sep** sets the separation character needed for parsing
    CSV files. If omitted, the separation character is auto-detected
    using the module `Text::CSV::Separator`.

  + **parser** => _fmt_

    The option **parser** sets the spreadsheet format. If omitted, the
    routine will try to detect it automatically be its MIME type.
    Known settings are: `csv`, `ods`, `xls`, `xlsx`.


## Requirements

+ [DataExtract::FixedWidth](https://metacpan.org/pod/DataExtract::FixedWidth)
+ [File::MimeInfo](https://metacpan.org/pod/File::MimeInfo)
+ [File::Temp](https://metacpan.org/pod/File::Temp)
+ [Scalar::Util](https://metacpan.org/pod/Scalar::Util)
+ [Spreadsheet::Read](https://metacpan.org/pod/Spreadsheet::Read)
+ [Spreadsheet::Write](https://metacpan.org/pod/Spreadsheet::Write)
+ [Text::CSV::Separator](https://metacpan.org/pod/Text::CSV::Separator)
+ [Text::Trim](https://metacpan.org/pod/Text::Trim)


## Contribution

Pull requests are welcome.  For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## License

[MIT](https://choosealicense.com/licenses/mit/)
