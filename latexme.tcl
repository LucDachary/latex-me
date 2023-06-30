#!/usr/bin/env expect
package require Tcl 8.5
package require cmdline 1.5.2

set options {
	{class.arg "article" "the Latex document's class"}
	{build "build the document after its creation"}
}
set usage ": latexme \[options] filename\noptions:"

try {
	array set params [::cmdline::getoptions argv $options $usage]
	# Note: argv is modified now. The recognized options are removed from it
	# leaving the non-option arguments behind.

	# Only 1 argument is expected now, others are options.
	if { [llength $argv] != 1 } {
		puts "error: I need exactly one argument, got [llength $argv]\n"
		puts "USAGE:"
		puts "\t$argv0 \[options\] FILENAME\n"
		puts "EXEMPLE:"
		puts "\t$argv0 new-article.tex"
		exit 1
	}
} trap {CMDLINE USAGE} {msg o} {
	puts $msg
	exit 1
}

# TODO if the filename does not end in ".tex", add the suffix?
set output_filepath [lindex $argv 0]
if [file exists $output_filepath] {
	puts "This exists already; doing nothing."
	exit 1
}
cd [file dirname $output_filepath]

# TODO add support for "report", "beamer", "scrlttr2".
set document_class $params(class)
if { $document_class != "article" } {
	puts {error: for now only the class "article" is supported.}
	exit 1
}

# Getting this script's location to locate templates.
# Resolve symlinks. Trick's source: https://wiki.tcl-lang.org/page/file+normalize.
set executable_filepath [file dirname [file normalize $argv0/tricky-part]]
set executable_dirpath [file dirname $executable_filepath]

set templates_dirpath [file join $executable_dirpath "templates"]
exec cp [file join $templates_dirpath "article.tex"] $output_filepath
puts "Latex \"$document_class\" document has been created at \"$output_filepath\"."

# TODO add a commandline option to execute this part.
if { $params(build) } {
	puts "Building…"
	set build_dirname "build"
	if {[file exists $build_dirname] && ![file isdirectory $build_dirname]} {
		puts "\"$build_dirname\" must be a directory and is not; doing nothing."
		exit 1
	}
	file mkdir $build_dirname

	set CTRL_D \004

	spawn xelatex --output-directory build $output_filepath
	expect {
		# TODO exit with error code?
		{Please type another input file name} {send $CTRL_D}
		{Package fontspec Error} {send $CTRL_D}
		default {puts "Document is built!"}
	}
}
