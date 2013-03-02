#----------------------------------------------------------
package MetaModel;
#----------------------------------------------------------

#----------------------------------------------------------
sub strat_MetaModel
#----------------------------------------------------------
{ 
    my $temp = $_;
    ($_) = @_;

    my $r = "";
    ( /\b(hi|hello|hey)\b/i    && ($r = "hi" )) ||
    ( /\b(i think|i know)\b/i  && ($r = "how do you know?" )) ||
    ( /intuition about you/i   && ($r = "Me too! Isn't it wonderful "
				    ."how quickly you can find yourself "
				    ."falling madly in love and spending "
				    ."lots of money?")) ||
    ( /\bwhat\b/i                && ($r = "wouldn't you like to know?")) ||
    ( /\b(yes|yep|yeah)\b/i      && ($r = "i knew it!")) ||
    ( /(i'm|i am) not/i          && ($r = "you aren't?" )) ||
    ( /i'm|i am/i                && ($r = "you are?" )) ||
    ( /\b(all|every|never)\b/i   && ($r = "$1?" )) ||
    ( /\b(every\w*|always)\b/i && ($r = "$1?")) ||
    ( /\bbye\b/i                 && ($r = "seeya")) ||
    ( /(m\/f|who are you|your name)\b/i 
                                 && ($r = "I'm Sabrina. I'm a very "
                                    ."good girl.")) ||
    ( /i can't/i                 && ($r = "what prevents you?")) ||
    ( /i don't know/i            && ($r= "i don't know either."
                                    ."why don't you take a guess?"));

    $_ = $temp;
    return $r;
}


1; # return true value so perl knows everything is okay here :)




