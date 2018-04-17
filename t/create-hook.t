use strict;
use warnings;
use Test::More;

use Role::NotSoTiny ();

my $last_role;
push @Role::NotSoTiny::ON_ROLE_CREATE, sub {
  ($last_role) = @_;
};

eval q{
  package MyRole;
  use Role::NotSoTiny;
};

is $last_role, 'MyRole', 'role create hook was run';

eval q{
  package MyRole2;
  use Role::NotSoTiny;
};

is $last_role, 'MyRole2', 'role create hook was run again';

done_testing;
