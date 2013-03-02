package ChatBot::ChatShop::ChatStack;

# ChatStack .01 :  a conversational framework for sabrina

sub new { 
    my $class = shift;
    my $self = {}; 
    bless $self, $class;
    $self->init();
    return $self;
}

sub init {
}

1; # return true value so perl knows everything is okay here :)

__END__
    
=head1 Why Stacks?
    
Any time sabrina gets an input, she should have some context
for which it makes sense. That is, the way she parses the input
"yes! that's exactly right!" has a lot to do with the whatever
she and the client have been talking about.
    
At any given moment, sabrina will expect some kind of response,
and for any input, she might generate several responses.
    
For simplicity's sake, she should probably stick to saying one
thing at a time. On the other hand, if I say "i have a cat" and
she comes up with 10 responses to it, it's not very efficient
to throw away 9. Instead, she should save them up, keeping a
list of things she wants to say or ask.

She doesn't have to USE all ten, mind you. Just keep track of
them.

=head1 Functional Requirements Spec

This module should:

=over 4

=item *

Make sure

=item *

=item *

=back

=cut











