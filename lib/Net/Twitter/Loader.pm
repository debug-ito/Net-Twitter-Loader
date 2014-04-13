package Net::Twitter::Loader;
use strict;
use warnings;

our $VERSION = "0.01";

1;
__END__

=pod

=head1 NAME

Net::Twitter::Loader - repeat loading Twitter statuses up to a certain point

=head1 SYNOPSIS

    use Net::Twitter::Loader;
    use Net::Twitter;
    
    my $input = Net::Twitter::Loader->new(
        backend => Net::Twitter->new(
            traits => [qw(OAuth API::RESTv1_1)],
            consumer_key => "YOUR_CONSUMER_KEY_HERE",
            consumer_secret => "YOUR_CONSUMER_SECRET_HERE",
            access_token => "YOUR_ACCESS_TOKEN_HERE",
            access_token_secret => "YOUR_ACCESS_TOKEN_SECRET_HERE",
            ssl => 1,
    
            #### If you access to somewhere other than twitter.com,
            #### set the apiurl option
            ## apiurl => "http://example.com/api/",
        ),
        filepath => 'next_since_ids.json',
        logger => sub {
            my ($level, $msg) = @_;
            warn "$level: $msg\n";
        },
    );
    
    ## First call to home_timeline
    my $arrayref_of_statuses = $input->home_timeline();
    
    ## The latest loaded status ID is saved to next_since_ids.json
    
    ## Subsequent calls to home_timeline automatically load
    ## all statuses that have not been loaded yet.
    $arrayref_of_statuses = $input->home_timeline();
    
    
    ## You can load other timelines as well.
    $arrayref_of_statuses = $input->user_timeline({screen_name => 'hoge'});
    
    
    foreach my $status (@$arrayref_of_statuses) {
        printf("%s: %s\n", $status->{user}{screen_name}, Encode::encode('utf8', $status->{text}));
    }


=head1 DESCRIPTION

This module is a wrapper for L<Net::Twitter> (or L<Net::Twitter::Lite>) to make it easy
to load a lot of statuses from timelines.

=head1 FEATURES

=over

=item *

It repeats requests to load a timeline that expands over multiple pages.
C<max_id> param for each request is adjusted automatically.

=item *

Optionally it saves the latest status ID to a file.
The file will be read to set C<since_id> param for the next request,
so that it can always load all the unread statuses.

=back

=head1 CLASS METHODS

=head2 $input = Net::Twitter::Loader->new(%options);

Creates the object with the following C<%options>.

=over

=item backend => OBJECT (mandatory)

Backend L<Net::Twitter> object. L<Net::Twitter::Lite> object can be used, too.

=item filepath => FILEPATH (optional)

File path for saving and loading the next C<since_id>.
If this option is not specified, no file will be created or loaded.

=item page_max => INT (optional, default: 10)

Maximum number of pages this module tries to load when C<since_id> is given.

=item page_max_no_since_id => INT (optional, default: 1)

Maximum number of pages this module tries to load when no C<since_id> is given.

=item page_next_delay => NUMBER (optional, default: 0)

Delay in seconds before loading the next page. Fractional number can be used.

=item logger => CODE (optional)

A code-ref for logging. If specified, it is called to log what this module is doing.

    $logger->($level, $message)

The logger is called with C<$level> and C<$message>.
C<$level> is the log level string (e.g. C<"debug">, C<"error"> ...) and C<$message> is the log message.

If C<logger> is omitted, the log is suppressed.

=back

=head1 OBJECT METHODS

=head2 $status_arrayref = $input->home_timeline($options_hashref)

=head2 $status_arrayref = $input->user_timeline($options_hashref)

=head2 $status_arrayref = $input->list_statuses($options_hashref)

=head2 $status_arrayref = $input->public_statuses($options_hashref)

=head2 $status_arrayref = $input->search($options_hashref)

=head2 $status_arrayref = $input->favorites($options_hashref)

=head2 $status_arrayref = $input->mentions($options_hashref)

=head2 $status_arrayref = $input->retweets_of_me($options_hashref)

Wrapper methods for corresponding L<Net::Twitter> methods. See L<Net::Twitter> for specification of C<$options_hashref>.

If C<since_id> is given in C<$options_hashref> or it is loaded from the file specified by C<filepath> option,
these wrapper methods repeatedly call L<Net::Twitter>'s corresponding methods to load a complete timeline newer than C<since_id>.
If C<filepath> option is enabled, the latest ID of the loaded status is saved to the file.

The max number of calling the backend L<Net::Twitter> methods is limited to C<page_max> option
if C<since_id> is specified or loaded from the file. The max number is limited to C<page_max_no_since_id> option
if C<since_id> is not specified.

If the operation succeeds, the return value of these methods is an array-ref of unique status objects.
If something is wrong (e.g. network failure), these methods throw an exception.

=head1 SEE ALSO

=head1 REPOSITORY

L<https://github.com/debug-ito/Net-Twitter-Loader>

=head1 BUGS AND FEATURE REQUESTS

Please report bugs and feature requests to my Github issues
L<https://github.com/debug-ito/Net-Twitter-Loader/issues>.

Although I prefer Github, non-Github users can use CPAN RT
L<https://rt.cpan.org/Public/Dist/Display.html?Name=Net-Twitter-Loader>.
Please send email to C<bug-Net-Twitter-Loader at rt.cpan.org> to report bugs
if you do not have CPAN RT account.


=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Toshio Ito.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

