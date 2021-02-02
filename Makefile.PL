use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Spreadsheet::Read::Simple',
    AUTHOR        => q{Matthias Boljen <matthias.boljen@emi.fraunhofer.de>},
    VERSION_FROM  => 'lib/Spreadsheet/Read/Simple.pm',
    ABSTRACT_FROM => 'lib/Spreadsheet/Read/Simple.pm',
    LICENSE       => 'perl',
    PL_FILES      => {},
    EXE_FILES     => [],
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'DataExtract::FixedWidth' => 0,
        'File::MimeInfo'          => 0,
        'File::Temp'              => 0,
        'Scalar::Util'            => 0,
        'Spreadsheet::Read'       => 0,
        'Spreadsheet::Write'      => 0,
        'Text::CSV::Separator'    => 0,
        'Text::Trim'              => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Spreadsheet-Read-Simple-*' },
);
