
package Role::NotSoTiny::Creator;

use 5.010;
use strict;
use warnings;

use Role::NotSoTiny ();

use Carp 'croak';

sub create_role {
  my ( $class, $package, %args ) = @_;
  my $methods = $args{methods} // {};
  Role::NotSoTiny->make_role($package);
  for my $meth ( keys %$methods ) {
    my $code = $methods->{$meth};
    croak qq{Not a coderef: $meth ($code)} unless ref $code eq 'CODE';
    no strict 'refs';
    *{"${package}::${meth}"} = $code;
  }
  return $package;
}

1;

=encoding utf8

=head1 NAME

Role::NotSoTiny::Creator - Experiment with Role::Tiny / Create roles programmatically

=head1 SYNOPSIS

  use Role::NotSoTiny::Creator ();

  my $role = Role::NotSoTiny::Creator->create_role(
    'Foo',
    methods => {
      foo => sub {...}
    },
  );

  # runtime equivalent of
  package Foo;
  use Role::Tiny;
  sub foo {...}

=head1 DESCRIPTION

This module is an experiment with L<Role::Tiny>.
It illustrates how the change in L<Role::NotSoTiny> makes easier
to build functionality such as a programmatic role creator.

=head1 METHODS

L<Role::NotSoTiny::Creator> implements the following methods.

=head2 make_role

  Role::NotSoTiny::Creator->create_role('Some::Package', methods => \%methods);

Prepares a given package as a role.
This is done by promoting the package to a L<Role::Tiny>
and adding the given methods to its stash.

=cut
