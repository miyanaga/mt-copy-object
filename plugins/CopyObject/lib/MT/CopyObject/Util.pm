package MT::CopyObject::Util;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT = qw(plugin);

sub plugin { MT->component('CopyObject') }

1;