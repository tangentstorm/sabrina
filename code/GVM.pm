## 
## GVM.pm - Generic Virtual Machine for Perl 
##
## Copyright (c) 1999 sabren.com
##
## This library is free software; you can redistribute it 
## and/or modify it under the same terms as Perl itself. 
##          

package GVM;

use strict;
no strict 'refs';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw( );

$VERSION = '0.01';


### Main GVM Methods #######################################

# create a new GVM object    
sub new {
    my $class = shift;
    my $self = {
	'_debug'  => 0,
	
	'R_IP'  => 0,
	'R_CMP' => 0,
	'R_AX'  => 0,
	'R_BX'  => 0,
	'R_CX'  => 0,
	
	'program' => ( 'end' ),
	
	'input'  => (),
	'output' => (),
    };
    
    bless $self, $class;
    return $self;
}
 
# load a program onto the GVM
sub load {
    my ($self, $program) = @_;
    $self->{'program'} = $program;
}


# input data into the GVM
sub input {
    my $self = shift;
    push @{$self->{'input'}}, @_;
}

# collect output from the GVM
sub output {
    my $self = shift;
    pop @{$self->{'output'}};
}

# perform one instruction
sub do_one_loop{

    my $self = shift;

    $self->{'R_IP'} >= 0 or return 0; # R_IP == -1 after "end"

    my $line = $self->{'program'}->{'opcode'}->[$self->{'R_IP'}]
	or return 0; # exit when no more opcodes.
    
    $self->{'_debug'} && print "$self->{R_IP}:\t$line\n";
    
    my @tokens = split "\t", $line;

    my $op = "i_". shift @tokens;
    
    $self->$op(@tokens);

    return 1;

}

# run the GVM's entire program
sub run{
    my $self = shift;
    while ($self->do_one_loop()) {}
}
    


### GCODE INSTRUCTION SET  #######################################

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


## end - end the program ##
sub i_end { 

    my $self = shift;
    $self->{'R_IP'} = -1;
}

## get - get a variable from input ##
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

    
## jlt - jump if less than ##
sub i_jlt {

    my $self = shift;

    $self->{'R_CMP'} < 0 ? $self->i_jmp(@_)
	: $self->{'R_IP'}++;
}
    

## jgt - jump if greater than ##
sub i_jgt {

    my $self = shift;

    $self->{'R_CMP'} > 0 ? $self->i_jmp(@_)
	: $self->{'R_IP'}++;
}

## jmp - jump ##
sub i_jmp {

    my $self = shift;
    my $dest = shift;

    $dest =~ s/^\:(\w+)/$self->{'program'}->{'label'}->{$1}/e;
    
    $self->{'R_IP'} = $dest;
    
}

## jne - jump if not equal ##
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

## put - output something ##
sub i_put {

    my $self = shift;
    my $l = shift; 

    $l =~ s/\$(\w+)/$self->{$1}/eg;  # interpolates variables..

    push @{$self->{'output'}}, $l; 

    $self->{'R_IP'}++;
}

## spd - change the speed of the virtual machine ##
sub i_spd { 

    my $self = shift;
    $self->{'R_SPD'} = shift;
    $self->{'R_IP'}++;
}

## wfr - wait for a particular input value ##
sub i_wfr { 
    
    my $self = shift;
    my $s = shift; 

    @{$self->{'input'}} && (my $t = shift @{$self->{'input'}});
    $self->{'R_IP'}++ if ($t eq $s);
}



1;
__END__


=head1 NAME

GVM - Generic Virtual Machine for Perl 

=head1 SYNOPSIS

  use GVM;

  $vm = new GVM;
  $vm->load( new GVM::Program "myprogram.txt" );

  $vm->input("test");
  $vm->run;

  print join "\n", @{$vm->{'output'}}, "";

 
=head1 DESCRIPTION

GVM provides a simple, extensible framework for creating virtual
machines and their instruction sets. It provides a basic instruction
set and can execute programs (g-code) written using these instructions.

=head2 Methods

=item $vm = new GVM
    
Creates a new virtual machine, sets all the registers
to zero, and creates a virtual program with a single "end" 
instruction.

=item $vm->load($program)
    
Loads a new program into the virtual machine memory. $program
can be an array, or a GVM::Program object.

=item $vm->input($data)

=item $vm->output()

=item $vm->do_one_loop()

=item $vm->run()

=head2 Registers

=item R_IP

The instruction pointer. This tells the GVM which instruction to
execute next. R_IP starts at zero, and usually increases by one 
after each instruction. However, some instructions act as GOTO
statements, and cause the instruction pointer to jump to other
sections of the g-code.

=item R_AX
=item R_BX
=item R_CX
=item R_CMP
=item R_SPD


=head2 Instruction Set

Because this is a I<generic> virtual machine, it can run any instruction
set you like. Simply create a subclass and give it methods corresponding
to the names of the instructions. For example, the instruction "xxx" would
require your GVM::subclass to have a method called "i_xxx".

The basic g-code instruction set contains the following instructions:

item cmp 
item end
item get
item jlt
item jgt
item jmp
item jne
item jze
item put

=head1 BUGS

I doubt anything works. :)

I seriously doubt anything works the way real virtual machine
geeks think it should. Tough. That's the reason I made it
GENERIC. If you don't like it, just make your own object
based on it that works the way you think it should.

I doubt the install works right. I never messed with
h2xs before I started this project, and I have no
clue how make works - yet.

=head1 TODO

I think it would be cool to make the whole GVM::Program
concept much more object-oriented.. You ought to be able to
read in programs compiled for other virtual machines - like
the z-machine old infocom games ran on, or the Java VM. 

Another alternative is to write converters that translate
code between other virtual machines and the ASCII format GVM
uses. That actually makes more sense, because GVM is used
more for messing around or prototyping than for actually 
running code.

I would really like to be able to compile programs into
bytecode rather than ascii... And maybe use actual stacks
to hold variables rather than relying on perl scalars
and arrays. But right now I just want to get this thing released,
so blah.

I also want to add these basic instructions:

mov - move a value into a variable or register

push - push something into a (not "the") stack
pop - pop something off a stack

and - boolean and
neg - negation (two's compliment?)
' - just a little apostrophe to fix the color in emacs.. :)
not - boolean not
or - boolean or
test - i forget, but It made sense in the x86 assembly reference
xor - boolean exclusive or
add - addition
sub - subtraction
mul - multiplication
div - division
loop - looping based on R_CX

=head1 AUTHOR

Michal Wallace, mwallace@sabren.com

=head1 COPYRIGHT

Copyright (c) 1999 sabren.com

This library is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself. 

=head1 SEE ALSO

Assembler, B, Bytecode, Ops, etc. for the internal Perl Virtual Machine.

=cut
