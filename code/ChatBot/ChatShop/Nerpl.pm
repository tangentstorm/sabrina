#----------------------------------------------------------
package Nerpl;
#----------------------------------------------------------
use GVM;
use GVM::Program;

$vm = new GVM;
$vm->load( new GVM::Program "../chocolate.nc" );

sub strat_Nerpl
{
    $vm->input(shift);
    $vm->do_one_loop until $vm->{'output'};
    return $vm->output;
}


1; # return true value so perl knows everything is okay here :)




