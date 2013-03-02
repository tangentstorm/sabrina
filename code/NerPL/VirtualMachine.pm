package NerPL::VirtualMachine;


####### instruction set ####################

## confirm ##
sub i_cfm {

    my $self = shift;
    my $l = shift @_; 

    $l =~ s/\$(\w+)/$self->{$1}/eg;  # interpolates variables..

    $self->{'R_CMP'} = 0;

    $l =~ /\b(yes|yep|yeah|sure|okay|ok)\b/i && ($self->{'R_CMP'} = 1);
    $l =~ /\b(no|not|nah)\b/i && ($self->{'R_CMP'} = -1);

    $self->{'R_IP'}++;
}
    
## compare ##
sub i_cmp { 

    my ($self, $a, $b) = @_;

    $a  =~ s/\$(\w+)/$self->{$1}/eg;  # interpolates variables..
    $b  =~ s/\$(\w+)/$self->{$1}/eg;  # interpolates variables..

    $self->{'R_CMP'} = 0;

    if ("$a$b" =~ /[^0-9]/) {

	$self->{'R_CMP'} = -1 if $a lt $b;
	$self->{'R_CMP'} = +1 if $a gt $b;

	print "stringy: R_CMP=$self->{R_CMP}\n";

    } else {

	$self->{'R_CMP'} = -1 if $a < $b;
	$self->{'R_CMP'} = +1 if $a > $b;

	print "numeric: R_CMP=$self->{R_CMP}\n";
    }

    
    
    $self->{'R_IP'}++ ;
}

## end ##
sub i_end { 

    my $self = shift;
    $self->{'R_IP'} = -1;
}

## get ##
sub i_get {
    
    my $self = shift;

    # wait for input.. 

    if (@{$self->{'input'}}) {

	my $s = shift;
	
	$s =~ s/^\$(\S)/$1/; 

	($self->{$s} = shift @{$self->{'input'}});

	$self->{'R_IP'}++;

    }
}

    
## jump if less than ##
sub i_jlt {

    my $self = shift;

    $self->{'R_CMP'} < 0 ? $self->i_jmp(@_)
	: $self->{'R_IP'}++;
}
    

## jump if greater than ##
sub i_jgt {

    my $self = shift;

    $self->{'R_CMP'} > 0 ? $self->i_jmp(@_)
	: $self->{'R_IP'}++;
}

## jump ##
sub i_jmp {

    my $self = shift;
    my $dest = shift;

    $dest =~ s/^\:(\w+)/$self->{'program'}->{'label'}->{$1}/e;
    
    $self->{'R_IP'} = $dest;
    
}

## jump if not equal ##
sub i_jne { 
    
    my $self = shift;
    $self->{'R_CMP'} ? $self->i_jmp(@_)
	: $self->{'R_IP'}++;
}


## jump if zero ##
sub i_jze {
    
    my $self = shift;
    $self->{'R_CMP'} ? $self->{'R_IP'}++
	: $self->i_jmp(@_);
}

## make something lowercase ##
sub i_lc {

    my $self = shift;
    my $arg = shift; 

    $arg =~ s/\$(\w+)/$1/g;  # interpolates variables..

    $self->{$arg} = lc($self->{$arg});

    $self->{'R_IP'}++;
}


## say ##
sub i_say {

    my $self = shift;
    my $l = shift; 

    $l =~ s/\$(\w+)/$self->{$1}/eg;  # interpolates variables..

    push @{$self->{'output'}}, $l; 

    $self->{'R_IP'}++;
}

## speed ##
sub i_spd { 

    my $self = shift;
    $self->{'R_SPD'} = shift;
    $self->{'R_IP'}++;
}

## waitfor ##
sub i_wfr { 
    
    my $self = shift;
    my $s = shift; 

    @{$self->{'input'}} && ($t = shift @{$self->{'input'}});
    $self->{'R_IP'}++ if ($t eq $s);
}
    
    
################################

sub load {

    my ($self, $program) = @_;

    $self->{'program'} = $program;
    
}

sub new {

    my $class = shift;

    my $self = {

	'_debug'  => 0,

	'R_IP' => 0,
	'R_CX' => 0,

	'nick' => shift,

	'program' => ( 'end' ),

	'input'  => (),
	'output' => (),

    };

    bless $self, $class;

    return $self;
}


sub input {
    my $self = shift;
    push @{$self->{'input'}}, @_;
}

sub output {
    my $self = shift;
    pop @{$self->{'output'}};
}


sub do_one_loop{

    my $self = shift;

    $self->{'R_IP'} >= 0 or return 0; # R_IP == -1 after "end"

    $line = $self->{'program'}->{'opcode'}->[$self->{'R_IP'}]
	or return 0; # exit when no more opcodes.
    
    $self->{'_debug'} && print "$self->{R_IP}:\t$line\n";
    
    @tokens = split "\t", $line;

    $op = "i_". shift @tokens;
    
    $self->$op(@tokens);

    return 1;

}


sub run{
    my $self = shift;
    while ($self->do_one_loop()) {}
}
    


1;



