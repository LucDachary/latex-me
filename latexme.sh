#!/usr/bin/env bash
#
# Latex-me Bash version.

# realpath is part of coreutils
BASE_DIR=$(dirname $(realpath $(which "$0")))

# Getting template names without the file extension.
CLASSES=($(ls $BASE_DIR/templates/*.tex | xargs -I _ basename _ .tex))

function usageErr() {
	printf 'Usage: %s [options] path/newfile.tex\n' "$0"
	printf '    -c [class]    The Latex class-template to use. Default is "notes".\n'
	printf '                  Available classes: %s\n' "${CLASSES[*]}"
	printf '    -b            Build the document upon creation, using xelatex.\n'
	printf '    -o            Overwrite the destination file if it exists.\n'
	printf '    -e            Open the new document in Vim with a build autocmd. Implies -b.\n'
	printf '    -v            Enable verbose outputs.\n'
	exit 2
} >&2

while getopts 'c:boev' opt; do
	case "${opt}" in
		c)
			CLASS="$OPTARG"
			if [[ ! ${CLASSES[@]} =~ (^|[[:space:]])$CLASS([[:space:]]|$) ]]; then
				printf '"%s" is not a valid class.\n' "$CLASS"
				usageErr
			fi
			;;
		b)
			BUILD=1
			;;
		o)
			OVERWRITE=1
			;;
		e)
			OPEN_VIM=1
			;;
		v)
			VERBOSE=1
			;;
	esac
done

shift $((OPTIND -1))

(( $# != 1 )) && usageErr

# Default class is "notes"
CLASS=${CLASS:-notes}
BUILD=${BUILD:-0}
OVERWRITE=${OVERWRITE:-0}
OPEN_VIM=${OPEN_VIM:-0}
VERBOSE=${VERBOSE:-0}

if (( $OVERWRITE == 0 )) && [[ -e "$1" ]]; then
	printf 'File "%s" already exists. Doing nothing.\n' "$1"
	exit 1
fi >&2

(( $VERBOSE )) && printf "I got the following arguments:\n\tclass = %s\n\tbuild = %s\n\toverwrite = %s\n\topen_vim = %s\n\tverbose = %s\n" \
	${CLASS} ${BUILD} ${OVERWRITE} $OPEN_VIM $VERBOSE

printf -v TEMPLATE_FILEPATH '%s/templates/%s.tex' "$BASE_DIR" "$CLASS"
(( $VERBOSE )) && printf 'Using template "%s"\n' "$TEMPLATE_FILEPATH"

cp "$TEMPLATE_FILEPATH" "$1"
printf 'I created file "%s".\n' "$1"

TARGET_BASE_DIR=$(dirname "$1")
printf -v BUILD_DIR '%s/build' "$TARGET_BASE_DIR"
if (( $OPEN_VIM || $BUILD )); then
	mkdir "$BUILD_DIR"
	if [[ ! -d "$BUILD_DIR" ]]; then
		printf 'Path "%s" is not a directory. Doing nothing.' "$BUILD_DIR"
		exit 1
	fi >&2

	xelatex --output-directory "$BUILD_DIR" "$1"
fi

if (( $OPEN_VIM )); then
	printf 'Yielding the process to Vim…\n'
	exec vim \
		"+autocmd BufWritePost <buffer> !xelatex --output-directory \"$BUILD_DIR\" \"<afile>\"" \
		"$1"
else
	printf "I'm done, happy writing!\n"
fi
