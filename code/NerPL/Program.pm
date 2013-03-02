package NerPL::Program;


sub new{

    my ($class, $filename) = @_;

    my $self = {
	opcode => [],
	label  => {},
    };
    
    open NCFILE, $filename;

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

##[TESTSTUFF]##
###############
##package main;
##$s = new NerPL::Program "../choices.nc";
##use Data::Dumper;
##print Dumper($s);

