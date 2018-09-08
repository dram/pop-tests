#!/bin/sh

POPLOG=poplog

TMP_PREFIX=pop-tests-
OUT_TMP=$(mktemp $TMP_PREFIX-out.XXXX)
ERR_TMP=$(mktemp $TMP_PREFIX-err.XXXX)
EXPECT_OUT_TMP=$(mktemp $TMP_PREFIX-expect-out.XXXX)
EXPECT_ERR_TMP=$(mktemp $TMP_PREFIX-expect-err.XXXX)
DIFF_OUT_TMP=$(mktemp $TMP_PREFIX-diff-out.XXXX)
DIFF_ERR_TMP=$(mktemp $TMP_PREFIX-diff-err.XXXX)

ALL_TMPS="$OUT_TMP $ERR_TMP"
ALL_TMPS="$ALL_TMPS $EXPECT_OUT_TMP $EXPECT_ERR_TMP"
ALL_TMPS="$ALL_TMPS $DIFF_OUT_TMP $DIFF_ERR_TMP"
trap "rm -f $ALL_TMPS" EXIT

succeed_count=0
fail_count=0
total_count=0

for source in builtin/* library/*
do
    case "$source" in
        *.p)
            program="$POPLOG pop11"
            ;;
        *.sh)
            program="env POPLOG=$POPLOG sh"
            ;;
        *)
            continue
    esac

    total_count=$(expr $total_count + 1)

    printf "[%04d] %-50s" $total_count "$source"

    $program "$source" >$OUT_TMP 2>$ERR_TMP

    program_exit=$?

    # FIXME: Remove verbose messages, Poplog should have an option to do that.
    if head -1 $OUT_TMP | grep -q '^Poplog Version'
    then
        sed -i "1,2d" $OUT_TMP
    fi

    # FIXME: Remove trailing spacespaces, should clean up Poplog output.
    sed -i 's/[ \t]*$//' $OUT_TMP
    sed -i 's/[ \t]*$//' $ERR_TMP

    # FIXME: Poplog should output filename identical to user supplied.
    sed -i "s|;;; FILE     :  .*$source|;;; FILE     :  $source|" $ERR_TMP

    grep -oP ';;; out\| \K.*' $source >$EXPECT_OUT_TMP
    grep -oP ';;; err\| \K.*' $source >$EXPECT_ERR_TMP

    diff -B -u $OUT_TMP $EXPECT_OUT_TMP >$DIFF_OUT_TMP
    out_diff_exit=$?

    diff -B -u $ERR_TMP $EXPECT_ERR_TMP >$DIFF_ERR_TMP
    err_diff_exit=$?

    if [ $program_exit -eq 0 -a $out_diff_exit -eq 0 -a $err_diff_exit -eq 0 ]
    then
        echo "[SUCCEED]"
        succeed_count=$(expr $succeed_count + 1)
    else
        echo "[FAIL]"
        fail_count=$(expr $fail_count + 1)

        if [ $program_exit -ne 0 ]
        then
            printf '[....] Program exit with %d.\n' $program_exit
        fi

        if [ $out_diff_exit -ne 0 ]
        then
            printf '[....] Output different from expected:\n'
            tail -n +3 $DIFF_OUT_TMP
            echo
        fi

        if [ $err_diff_exit -ne 0 ]
        then
            printf '[....] Error different from expected:\n'
            tail -n +3 $DIFF_ERR_TMP
            echo
        fi
    fi
done

cat <<EOF

============
TEST SUMMARY
============
Failed: $fail_count
Succeeded: $succeed_count
EOF
