:NAME
put	hi! what's your name?
get	$name
put	hello, $name
:LIKECHOC
put	do you like chocolate?
get	$yesno
cfm	$yesno
jze	:LIKECHOC
jlt	:HATEIT
put	i like chocolate too.
end
:HATEIT
put	i hate chocolate!
end
