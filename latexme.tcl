#!/usr/bin/env expect
if { $argc != 2 } {
	puts "error: I need exactly two arguments\n"
	puts "USAGE:"
	puts "\t$argv0 CLASS FILENAME\n"
	puts "EXEMPLE:"
	puts "\t$argv0 article new-article.tex"
	exit 1
}

# TODO make sure the FILENAME does not contain a path. Or then move to this location?
# TODO if the filename does not end in ".tex", add the suffix.

# TODO add "letter" with "scrlttr2
if { [lindex $argv 0] != "article" } {
	puts {error: for now only the class "article" is supported.}
	exit 1
}

# TODO prepend the path to the latex-me installation directory.
set template_article "templates/article.tex"

exec cp $template_article [lindex $argv 1]
