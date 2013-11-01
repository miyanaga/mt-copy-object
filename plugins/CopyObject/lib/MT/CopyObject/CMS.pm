package MT::CopyObject::CMS;

use strict;
use warnings;

use MT::CopyObject::Util;

sub on_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $q = $app->param;
    return 1 if $q->{new_object};

    my $header_include = $tmpl->getElementById('header_include');
    my $copy_label = $param->{object_type} eq 'page'
        ? plugin->translate('Copy As New Page')
        : plugin->translate('Copy As New Entry');

    if ( $q->param('_copy') ) {
        delete $param->{id};
        $param->{new_object} = 1;
        $param->{copy_object} = 1;

        $param->{title} = plugin->translate('Copy of [_1]', $param->{title});
        $param->{copied_label} = plugin->translate('Copy from <a href="[_1]">id:[_2]</a>',
            $app->uri( mode => 'view', args => {
                _type => $q->param('_type'),
                id => $q->param('id'),
                blog_id => $q->param('blog_id'),
            }),
            $q->param('id'),
        );

        my $setvarblock = $tmpl->createElement( 'setvarblock', {
            name => 'page_title',
            append => 1,
        });
        $setvarblock->innerHTML(q{
            <small><mt:var name="copied_label"></small>
        });
        $tmpl->insertBefore($setvarblock, $header_include);        

    } else {

        my $setvarblock = $tmpl->createElement( 'setvarblock', {
            name => 'page_title',
            append => '1',
        });
        $setvarblock->innerHTML(q{
            <small><a href="<mt:var name='copy_link' escape='html'>"><mt:var name='copy_label'></a></small>
        });
        $tmpl->insertBefore($setvarblock, $header_include);
        $param->{copy_label} = $copy_label;
        $param->{copy_link} = $app->uri( mode => 'view', args => {
            _type => $q->param('_type'),
            id => $q->param('id'),
            blog_id => $q->param('blog_id'),
            _copy => 1,
        });

    }

    1;
}

sub _next_field {
    my ( $obj, $guess, $index ) = @_;
    my %values;

    my $basename = $obj->basename;


}

sub copy_fields {
    my $app = shift;
    $app->validate_magic or return;

    my $xhr = $app->param('xhr');
    my @id  = $app->param('id');

    require MT::Tag;
    my $copies = int($app->param('itemset_action_input'));
    return $xhr ? undef : $app->call_return unless $copies;

    my %indexes;
    my %templates;
    for ( my $i = 0; $i < $copies; $i++ ) {
        foreach my $id ( @id ) {
            my $obj = MT->model('field')->load($id);
            $obj->{column_values}{id} = undef;

            my $basename = $obj->basename;
            my $name = $obj->name;
            my $tag = $obj->tag;

            # Guess index
            my @guess = $basename =~ /([0-9]+)/;
            my $guess = @guess ? ( shift @guess ) : undef;

            my $index = ( $indexes{$obj->basename} ||= $guess || 0 );
            my $continue = 1;
            my $new_basename = $basename;
            my $new_tag = $tag;
            my $new_name = $name;

            while ( $continue ) {
                $index++;
                print STDERR $index, "\n";

                if ( defined $guess ) {
                    $new_basename =~ s!$guess!$index!;

                    if ( $name =~ m!$guess! ) {
                        $new_name =~ s!$guess!$index!;
                    } else {
                        $new_name .= '(' . $index . ')';
                    }

                    if ( $tag =~ m!$guess! ) {
                        $new_tag =~ s!$guess!$index!;
                    } else {
                        $new_tag .= '_' . $index;
                    }
                } else {
                    $new_basename .= '_' . $index;
                    $new_name .= '_' . $index;
                    $new_tag .= '_' . $index;
                }

                next if MT->model('field')->load({
                    blog_id => $obj->blog_id,
                    basename => $new_basename,
                });
                next if MT->model('field')->load({
                    blog_id => $obj->blog_id,
                    tag => $new_tag,
                });

                last;
            }

            $obj->basename($new_basename);
            $obj->name($new_name);
            $obj->tag($new_tag);
            $obj->save;
        }
    }

    $app->add_return_arg( 'saved' => 1 );
    return $xhr
        ? {
        messages => [
            {   cls => 'success',
                msg => plugin->translate(
                    'Successfully [_1] time(s) copied about [_2] field(s).',
                    $copies, scalar @id,
                )
            }
        ]
        }
        : $app->call_return;
}

1;