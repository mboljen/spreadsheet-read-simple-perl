# Copyright 2018 Matthias Boljen.  All rights reserved.
#
# Created:         Mo 2019-08-26 11:55:21 CEST
# Last Modified:   Wed 2024-02-14 18:29:40 CET
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Spreadsheet::Read::Simple;

use strict;
use warnings;

use parent qw(Spreadsheet::Read);

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw(&ReadDataSimple);
%EXPORT_TAGS = ( 'all' => [ qw() ] );
@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = 0.01;

use Carp;
use Data::Dumper;
use DataExtract::FixedWidth;
use File::MimeInfo;
use File::Temp;
use FindBin qw($Bin $Script);
use Scalar::Util qw(openhandle);
use Spreadsheet::Read;
use Spreadsheet::Write;
use Text::CSV::Separator qw(get_separator);
use Text::Trim;

=encoding utf8

=head1 NAME

Spreadsheet::Read::Simple - Simplified Spreadsheet Reader

=head1 SYNOPSIS

    # Include module
    use Spreadsheet::Read::Simple;

    # Read spreadsheet
    my $book = ReadDataSimple($file);

=head1 REQUIRES

DataExtract::FixedWidth, File::MimeInfo, File::Temp, Scalar::Util,
Spreadsheet::Read, Spreadsheet::Write, Text::CSV::Separator, Text::Trim

=head1 DESCRIPTION

This module combines the capabilities of the modules B<Spreadsheet::Read>
and B<DataExtract::FixedWidth> in order to being able to parse conventional
spreadsheets and text files with data in fixed width columns.

The latter is being achieved by converting the text file with fixed width
columns to a temporary CSV spreadsheet and parsing the temporary spreadsheet
using the method B<ReadData> provided by B<Spreadsheet::Read>.

=head1 EXPORT

The following symbols are exported.

=over

=item B<&ReadDataSimple>

=back

=head1 SUBROUTINES

=over 4

=item B<ReadDataSimple>(F<source> [, I<option> => I<value> [, ... ]])

The subroutine B<ReadDataSimple> is a wrapper for the subroutine B<ReadData>.
It receives a mandatory argument F<source> which can be the name of file
or a file handle.  If it is a file several checks are being performed in
order to identify text files with fixed width columns.  If these checks
are positive the text file is converted to an temporary CSV file and
afterwards parsed using the ordinary subroutine B<ReadData>.
The subroutine B<ReadDataSimple> may receive additional arguments in
key-value-syntax.  Refer to the documentation of B<Spreadsheet::Read> for
details.  The following options are recognized:

=over 4

=item B<sep> => I<char>

The option B<sep> sets the separation character needed for parsing CSV files.
If omitted, the separation character is auto-detected using the module
B<Text::CSV::Separator>.

=item B<parser> => I<fmt>

The option B<parser> sets the spreadsheet format.  If omitted, the routine
will try to detect it automatically be its MIME type.  Known settings are:
C<csv>, C<ods>, C<xls>, C<xlsx>.

=back

=cut

sub ReadDataSimple
{
    # Fetch argument
    my $src = shift;

    #
    croak "Invalid number of options" if @_ % 2;
    my %params = @_;

    # Check if source is defined
    croak "Undefined source" unless defined $src;

    # Replace separation character aliases
    if (defined $params{sep})
    {
        $params{sep} =~ s/^(?:white)?spaces?$/ /i;
        $params{sep} =~ s/^tab(?:ulator)?s?$/\t/i;
    }

    # Check MIME-type unless file handle
    unless (defined openhandle($src))
    {
        # Check if file exists
        croak "File not found: $src" unless -f $src;

        # Check MIME type
        unless (exists $params{parser})
        {
            #
            my $mimetype = mimetype($src);
            if ($mimetype =~ /^text\/(?:plain|csv|x-log)$/)
            {
                # Plain text or CSV file
                $params{parser} = 'csv';
            }
            elsif ($mimetype eq 'application/vnd.ms-excel')
            {
                # Microsoft XLS file
                $params{parser} = 'xls';
            }
            elsif ($mimetype eq 'application/vnd.'.
                                    'oasis.opendocument.spreadsheet')
            {
                # OpenDocument Spreadsheet
                $params{parser} = 'ods';
            }
            elsif ($mimetype eq 'application/vnd.'.
                                    'openxmlformats-officedocument.'.
                                    'spreadsheetml.sheet')
            {
                # Microsoft XLSX file
                $params{parser} = 'xlsx';
            }
            else
            {
                # Unknown MIME type
                carp "Unknown MIME type $mimetype: $src";
            }
        }

        # Auto-detect separation character
        if (not exists $params{sep} or (not defined $params{sep} and
                                                    $params{parser} eq 'csv'))
        {
            my @chars = get_separator(path => $src, include => [' ']);
            if (@chars)
            {
                $params{sep} = shift @chars;
                carp "Auto-detected separator `$params{sep}` for $src";
            }
            else
            {
                carp "Failed to auto-detect separator for $src";
            }
        }
    }

    # Result reference
    my $ref;

    # Check whether fixed width column text file is input
    if (defined $params{parser} and $params{parser} =~ /^csv$/i and
        defined $params{sep} and $params{sep} eq ' ')
    {
        # Assign CSV type
        $params{parser} = 'csv';

        # Read text file
        my @rows;
        open IN, '<' . $src or croak "Cannot open $src: $!";
        while (<IN>) { chomp; push @rows, $_; }
        close IN or croak "Cannot close $src: $!";

        # Create temporary data object
        my $de = DataExtract::FixedWidth->new({
                header_row => undef,
                heuristic => \@rows,
        });

        # Create temporary CSV file
        my $fh = File::Temp->new( $Script . '-XXXXXX',
            SUFFIX => '.csv',
            TMPDIR => 1,
        );
        my $tempfile = $fh->filename;
        my $out = Spreadsheet::Write->new(
            file     => $tempfile,
            format   => 'csv',
            encoding => 'utf8',
        );
        die $out->error() if $out->error;
        $out->addrow( @{ $de->parse($_) } ) for @rows;
        $out->close();

        # Parse temporary CSV file using Spreadsheet::Read
        $ref = ReadData($tempfile,
            parser => $params{parser},
            sep    => ',',
            clip   => 1,
            strip  => 3,
        );
    }
    elsif ($params{parser} =~ /^(?:csv|ods|sxc|xlsx?)$/i)
    {
        # Parse conventional spreadsheet using Spreadsheet::Read
        $ref = ReadData($src,%params);
    }

    # Return blessed reference
    bless $ref, 'Spreadsheet::Read';
}

=back

=head1 COPYRIGHT AND LICENSE

MIT License

Copyright (c) 2021 Matthias Boljen

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

=cut

1;
