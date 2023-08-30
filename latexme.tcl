#!/usr/bin/env expect
package require Tcl 8.5
package require cmdline 1.5.2

set options {
	{class.arg "article" "the Latex document's class"}
	{build "Build the document after its creation."}
	{ow "Overwrite the destination file if it exists already."}
	{vim "Open the document in Vim, with building autocmd. This implies -build."}
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
if {!$params(ow) && [file exists $output_filepath]}  {
	puts "This file exists already; doing nothing."
	exit 1
}
cd [file dirname $output_filepath]

set document_class $params(class)
switch $params(class) {
	article { set document_class "article" }
	report { set document_class "report" }
	scrlttr2 -
	letter { set document_class "scrlttr2" }
	beamer -
	presentation { set document_class "beamer" }
	default {
		puts "Unknown class \"$params(class)\". Aborting."
		exit 1
	}
}

# Getting this script's location to locate templates.
# Resolve symlinks. Trick's source: https://wiki.tcl-lang.org/page/file+normalize.
set executable_filepath [file dirname [file normalize $argv0/tricky-part]]
set executable_dirpath [file dirname $executable_filepath]

set templates_dirpath [file join $executable_dirpath "templates"]
set template_filepath [file join $templates_dirpath [string cat $document_class ".tex"]]
if { ![file exists $template_filepath] } {
	puts "Cannot find the template for the class \"$document_class\". Aborting."
	exit 1
}
exec cp $template_filepath $output_filepath
puts "Latex \"$document_class\" document has been created at \"$output_filepath\"."

if { $params(build) || $params(vim) } {
	puts "Building…"
	set build_dirname "build"
	if {[file exists $build_dirname] && ![file isdirectory $build_dirname]} {
		puts "\"$build_dirname\" must be a directory and is not; doing nothing."
		exit 1
	}
	file mkdir $build_dirname

	set CTRL_D \004

	spawn xelatex --output-directory $build_dirname $output_filepath
	expect {
		# TODO exit with error code?
		# TODO improve xelatex's errors handling.
		{Please type another input file name} {send $CTRL_D}
		{Package fontspec Error} {send $CTRL_D}
		default {puts "Document is built!"}
	}
}

# TODO add option to open Vim at the end, with autocmd to build the document
if { $params(vim) } {
	puts "Giving control to Vim…"
	# TODO use $build_dirname instead of hardcoded "build"
	overlay vim "+autocmd BufWritePost <buffer> !xelatex --output-directory $build_dirname \"<afile>\"" $output_filepath
}
