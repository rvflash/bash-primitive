#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../strings.sh

# Default entries
declare -r TEST_STRINGS_MASK="()"
declare -r -i TEST_STRINGS_CHK=3159589107
declare -r TEST_STRINGS_WITHOUT_SPACES="Text without leading or trailing spaces"
declare -r TEST_STRINGS_WITH_LEADING_SPACES=" ${TEST_STRINGS_WITHOUT_SPACES}"
declare -r TEST_STRINGS_WITH_TRAILING_SPACES="${TEST_STRINGS_WITHOUT_SPACES} "
declare -r TEST_STRINGS_WITH_SPACES=" ${TEST_STRINGS_WITHOUT_SPACES} "
declare -r TEST_STRINGS_WITH_TABS_AND_SPACES="  ${TEST_STRINGS_WITHOUT_SPACES} "
declare -r TEST_STRINGS_WITH_SPACES_AND_MASK=" ( ${TEST_STRINGS_WITHOUT_SPACES} )"

readonly TEST_STRINGS_CHECKSUM="-11-01-01-01-01"

function test_checksum ()
{
    local TEST CONFIRM_TEST

    # Check nothing
    TEST=$(checksum)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check
    TEST=$(checksum "${TEST_STRINGS_WITHOUT_SPACES}")
    echo -n "-$?"
    [[ "$TEST" -gt 0 ]] && echo -n 1

    # Confirm previous check
    CONFIRM_TEST=$(checksum "${TEST_STRINGS_WITHOUT_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$CONFIRM_TEST" && "$TEST" -eq ${TEST_STRINGS_CHK} ]] && echo -n 1

    # Check with leading spaces and expect no change
    TEST=$(checksum "${TEST_STRINGS_WITH_LEADING_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$CONFIRM_TEST" && "$TEST" -eq ${TEST_STRINGS_CHK} ]] && echo -n 1

    # Check with an other text and expect new hash
    CONFIRM_TEST=$(checksum "${TEST_STRINGS_WITHOUT_SPACES:10}")
    echo -n "-$?"
    [[ "$CONFIRM_TEST" -gt 0 && "$TEST" != "$CONFIRM_TEST" && "$TEST" -eq ${TEST_STRINGS_CHK} ]] && echo -n 1
}

readonly TEST_STRINGS_EMPTY="-01-01-01-01-01-01-11"

function test_isEmpty ()
{
    local TEST

    # Check nothing
    TEST=$(isEmpty)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check isEmpty string
    TEST=$(isEmpty "")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check isEmpty array
    TEST=$(isEmpty "()")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check zero as int
    TEST=$(isEmpty "0")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check zero as float
    TEST=$(isEmpty "0.0")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check boolean
    TEST=$(isEmpty false)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check not nothing
    TEST=$(isEmpty true)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1
}


readonly TEST_STRINGS_TRIM="-01-01-01-01-01-01"

function test_trim ()
{
    local TEST

    # Check nothing
    TEST=$(trim)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with leading spaces
    TEST=$(trim "${TEST_STRINGS_WITH_LEADING_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$TEST_STRINGS_WITHOUT_SPACES" ]] && echo -n 1

    # Check with trailing spaces
    TEST=$(trim "${TEST_STRINGS_WITH_TRAILING_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$TEST_STRINGS_WITHOUT_SPACES" ]] && echo -n 1

    # Check with leading and trailing spaces
    TEST=$(trim "${TEST_STRINGS_WITH_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$TEST_STRINGS_WITHOUT_SPACES" ]] && echo -n 1

    # Check with leading and trailing spaces or tabs
    TEST=$(trim "${TEST_STRINGS_WITH_TABS_AND_SPACES}")
    echo -n "-$?"
    [[ "$TEST" == "$TEST_STRINGS_WITHOUT_SPACES" ]] && echo -n 1

    # Check with leading and trailing spaces and masks
    TEST=$(trim "${TEST_STRINGS_WITH_SPACES_AND_MASK}" "${TEST_STRINGS_MASK}")
    echo -n "-$?"
    [[ "$TEST" == "$TEST_STRINGS_WITHOUT_SPACES" ]] && echo -n 1
}


# Launch all functional tests
bashUnit "checksum" "${TEST_STRINGS_CHECKSUM}" "$(test_checksum)"
bashUnit "isEmpty" "${TEST_STRINGS_EMPTY}" "$(test_isEmpty)"
bashUnit "trim" "${TEST_STRINGS_TRIM}" "$(test_trim)"