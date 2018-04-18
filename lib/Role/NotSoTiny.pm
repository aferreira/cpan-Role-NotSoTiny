
package Role::NotSoTiny;

use strict;
use warnings;

BEGIN {
  require Role::Tiny;
  Role::Tiny->VERSION('2.000005');
  our @ISA = qw(Role::Tiny);
}

# Aliasing of Role::Tiny symbols
BEGIN {
  *INFO           = \%Role::Tiny::INFO;
  *APPLIED_TO     = \%Role::Tiny::APPLIED_TO;
  *ON_ROLE_CREATE = \@Role::Tiny::ON_ROLE_CREATE;

  *_getstash = \&Role::Tiny::_getstash;
  *_getglob  = \&Role::Tiny::_getglob;
}

our %INFO;
our %APPLIED_TO;
our @ON_ROLE_CREATE;

sub import {
  my $target = caller;
  my $me     = shift;
  strict->import;
  warnings->import;
  $me->_install_subs($target);
  $me->make_role($target);
}

sub make_role {
  my ( $me, $target ) = @_;
  return if $me->is_role($target);    # already exported into this package
  $INFO{$target}{is_role} = 1;
  # get symbol table reference
  my $stash = _getstash($target);
  # grab all *non-constant* (stash slot is not a scalarref) subs present
  # in the symbol table and store their refaddrs (no need to forcibly
  # inflate constant subs into real subs) with a map to the coderefs in
  # case of copying or re-use
  my @not_methods
    = map +( ref $_ eq 'CODE' ? $_ : ref $_ ? () : *$_{CODE} || () ),
    values %$stash;
  @{ $INFO{$target}{not_methods} = {} }{@not_methods} = @not_methods;
  # a role does itself
  $APPLIED_TO{$target} = { $target => undef };
  foreach my $hook (@ON_ROLE_CREATE) {
    $hook->($target);
  }
}

1;

=encoding utf8

=head1 NAME

Role::NotSoTiny - Experiment with Role::Tiny / Role::NotSoTiny->make_role()

=head1 SYNOPSIS

  use Role::NotSoTiny ();

  Role::NotSoTiny->make_role('Foo');
  *Foo::foo = sub {...};

  # runtime equivalent of
  package Foo;
  use Role::Tiny;
  sub foo {...}

=head1 DESCRIPTION

This module is an experiment with L<Role::Tiny>.
The change here is being a proposed as a patch to the original code.
See L<https://github.com/moose/Role-Tiny/pull/4>.

=head1 METHODS

L<Role::NotSoTiny> inherits all methods of L<Role::Tiny> and
implements the following new ones.

=head2 make_role

  Role::NotSoTiny->make_role('Some::Package');

Promotes a given package to a role.
No subroutines are imported into C<'Some::Package'>.

=cut
