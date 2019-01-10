use strict;
use warnings;
use Test::More;
use Exporter::unimport;

{
  package Foo;
  use Scalar::Util qw(looks_like_number);
  BEGIN {
    ::ok __PACKAGE__->can('looks_like_number');
  }
  no Scalar::Util;
  ::ok !__PACKAGE__->can('looks_like_number');
}

done_testing;
