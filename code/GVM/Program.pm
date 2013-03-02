package GVM::Program;

sub new{

    my ($class, $filename) = @_;

    my $self = {
	opcode => [],
	label  => {},
    };
    
    open NCFILE, $filename or die "can't load $filename: $!";

    while (<NCFILE>) { 

	chomp;

	/^\:(\w+)/ ? ($self->{'label'}->{$1} = $#{$self->{opcode}} + 1)
                   : push @{$self->{opcode}}, $_;
    }

    close NCFILE;

    bless $self, $class;

    return $self;
}



sub compile { die "can't compile yet" }

1;
