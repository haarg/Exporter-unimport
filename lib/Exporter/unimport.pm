package Exporter::unimport;
use strict;
use warnings;

our $VERSION = '0.001000';
$VERSION =~ tr/_//d;

use namespace::clean ();
use Exporter; *import = \&Exporter::import;

our @EXPORT = qw(unimport);

sub unimport {
  my $exporter = shift;
  my $caller = caller;
  my @to_remove;
  no strict 'refs';
  my @export = @{$exporter.'::EXPORT'};
  my @export_ok = @{$exporter.'::EXPORT_OK'};
  my %export_tags = %{$exporter.'::EXPORT_TAGS'};
  if (@_) {
    for my $remove (@_) {
      if ($remove =~ /\A:(.*)/s) {
        if ($1 eq 'DEFAULT') {
          push @to_remove, @export;
        }
        else {
          push @to_remove, @{$export_tags{$1}};
        }
      }
      else {
        if ($remove =~ /\A[@%*\$]/) {
          die "can't unexport non-subs: $remove";
        }
        push @to_remove, $remove;
      }
    }
  }
  else {
    push @to_remove, @export, @export_ok, map @$_, values %export_tags;
  }
  my %s;
  @to_remove =
    grep exists &{$caller.'::'.$_} && \&{$caller.'::'.$_} == \&{$exporter.'::'.$_},
    grep !$s{$_}++,
    map { /\A&?([^@%*\$&].*)/s ? $1 : () }
    @to_remove;
  namespace::clean->clean_subroutines($caller, @to_remove);
}

*Exporter::unimport = \&unimport;

1;
__END__

=pod

=encoding utf-8

=head1 NAME

Exporter::unimport - Unimporter for Exporter

=head1 SYNOPSIS

  use Exporter::unimport;
  use Scalar::Util qw(looks_like_number);
  my $v = looks_like_number(1) ? 'true' : 'false';
  # true
  no Scalar::Util;
  my $f = __PACKAGE__->can('looks_like_number') ? 'true' : 'false';
  # false

=head1 DESCRIPTION

Provides an unimporter for Exporter based modules.

=head1 AUTHORS

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None so far.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019 the Test::Needs L</AUTHORS> and L</CONTRIBUTORS>
as listed above.

This library is free software and may be distributed under the same terms
as perl itself. See L<http://dev.perl.org/licenses/>.

=cut
