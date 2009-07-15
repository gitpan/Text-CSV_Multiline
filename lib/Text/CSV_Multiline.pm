package Text::CSV_Multiline;

use strict;
use warnings;

use base "Exporter";
use Fcntl ":seek";

our @EXPORT = qw(
	csv_quote
	csv_unquote
	csv_read_record
	csv_write_record
);

our $VERSION = '0.01';
our $ALWAYS_USE_QUOTES = 0;

sub csv_quote
{
	my $value = shift;
	$value = "" if not defined $value;
	if ($value =~ /^[\w\d.]*$/s && !$ALWAYS_USE_QUOTES)
	{
		return $value;
	}
	$value =~ s/"/""/gs;
	return "\"$value\"";
}

sub csv_unquote
{
	my $quoted = shift;
	$quoted =~ s/^\s+//s;
	$quoted =~ s/\s+$//s;
	if ($quoted =~ /^"(.*)"$/s)
	{
		$quoted = $1;
		$quoted =~ s/""/"/gs;
	}
	#print STDERR "found field: >$quoted<\n";
	return $quoted;
}

sub csv_read_record
{
	my $fh = shift;
	my @parts = ();
	my $line = "";
	my $num_lines = 0;
	while (<$fh>)
	{
		$line .= $_;
		my $quoted_field = qr/"(?:[^"]|"")*"/;
		my $unquoted_field = qr/[^,"]*/;
		my $field = qr/\s*(?:$quoted_field|$unquoted_field)\s*/;

		while ($line =~ s/^($field),//s)
		{
			push @parts, csv_unquote($1);
		}

		if ($line =~ /^($field)$/s)
		{
			# last field
			push @parts, csv_unquote($1);
			return @parts;
		}
	}
	if (length($line))
	{
		warn "detected eof before last field was finished\n";
		warn "-->$line<--\n";
	}
	return @parts;
}

sub csv_write_record
{
	my $fh = shift;
	my @values = @_;
	print $fh join(",", map { csv_quote($_) } @values) . "\n";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Text::CSV_Multiline - comma-separated values manipulation routines

=head1 SYNOPSIS

  use Text::CSV_Multiline;

  # reading in a CSV file
  while (my @values = csv_read_record(\*STDIN))
  {
      # do stuff
  }

  # writing a CSV file
  foreach my $data (@rows)
  {
      csv_write_record(\*STDOUT, @$data);
  }

=head1 DESCRIPTION

Stub documentation for Text::CSV_Multiline, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>jlong@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
