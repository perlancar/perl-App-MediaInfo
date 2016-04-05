package App::MediaInfo;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
#use Log::Any '$log';

our %SPEC;

$SPEC{media_info} = {
    v => 1.1,
    summary => 'Get information about media files/URLs',
    args => {
        media => {
            summary => 'Media files/URLs',
            schema => ['array*' => of => 'str*'],
            req => 1,
            pos => 0,
            greedy => 1,
            #'x.schema.entity' => 'filename_or_url',
            'x.schema.entity' => 'filename', # temp
        },
        backend => {
            summary => 'Choose a specific backend',
            schema  => ['str*', match => '\A\w+\z'],
            completion => sub {
                require Complete::Module;
                my %args = @_;
                Complete::Module::complete_module(
                    word => $args{word},
                    ns_prefix => "Media::Info",
                );
            },
        },
    },
};
sub media_info {
    require Media::Info;

    my %args = @_;

    my $media = $args{media};

    if (@$media == 1) {
        return Media::Info::get_media_info(
            media => $media->[0],
            (backend => $args{backend}) x !!(defined $args{backend}),
        );
    } else {
        my @res;
        for (@$media) {
            my $res = Media::Info::get_media_info(
                media => $_,
                (backend => $args{backend}) x !!(defined $args{backend}),
            );
            unless ($res->[0] == 200) {
                warn "Can't get media info for '$_': $res->[1] ($res->[0])\n";
                next;
            }
            push @res, { media => $_, %{$res->[2]} };
        }
        [200, "OK", \@res];
    }
}

1;
# ABSTRACT: