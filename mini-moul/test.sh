source config.sh

readonly DATA=$(cat data.json)

#utils
index=0
index2=0
assignment_data=NULL
test_data=NULL
test_error=NULL
test_name=NULL

#variables
checks=0
passed=0
marks=0
questions=0
dirname_found=0
break_score=0
score_false=0
available_assignments=""
result=""
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dirname_found=0

main()
{
    #print_collected_files
    for dir in ./tests/* ; do
        dirname="$(basename "$dir")"
        available_assignments+="$dirname "
        
        if [ -d "$dir" ] && [ "$dirname" == "$1" ]; then
            dirname_found=1
            print_header
            printf "${GREEN} Generating test for ${1}...\n${DEFAULT}"
            space
            dirname_found=1
            index=0
            
            for assignment in $dir/*; do
                questions=$((questions+1))
                score_false=0
                assignment_name="$(basename "$assignment")"
                #file_name=$(echo "$DATA" | jq -r ".$dirname[] | select(.exercise == \"$assignment_name\").file")
                test_name="$(ls $assignment/*.c | head -n 1)"
                test_name="$(basename "$test_name")"
                #assignment_data=$(echo "$DATA" | jq -r ".$dirname[] | select(.exercise == \"$assignment_name\")")
                
                if cc -o test1 $(ls $assignment/*.c | head -n 1) 2> /dev/null; then
                    rm test1
                    checks=$((checks+1))
                    passed=$((passed+1))
                    
                    if [ -d "$assignment" ]; then
                        index2=0
                        
                        for test in $assignment/*.c; do
                            ((index2++))
                            checks=$((checks+1))
                            #set_test_data
                            
                            if cc -o ${test%.c} $test 2> /dev/null; then
                                
                                if ./${test%.c} = 0; then
                                    passed=$((passed+1))
                                else
                                    break_score=1
                                    score_false=1
                                fi
                                rm ${test%.c}
                            else
                                printf "    ""${GREY}[$(($index2+1))] $test_error ${RED}FAILED${DEFAULT}\n"
                            fi
                        done
                        print_test_result
                        ((index++))
                        space
                    else
                        printf "${RED}    $assignment_name does not exist.${DEFAULT}\n"
                    fi
                else
                    break_score=1
                    checks=$((checks+1))
                    printf "${RED}    $test_name cannot compile.${DEFAULT}\n"
                    printf "${BG_RED}${BOLD} FAIL ${DEFAULT}${PURPLE} $assignment_name/${DEFAULT}$test_name\n"
                    space
                    
                    if [ $index -gt 0 ]; then
                        result+=", "
                    fi
                    result+="${RED}$assignment_name: KO${DEFAULT}"
                fi
            done
            break
        fi
    done
    
    if [ $dirname_found = 0 ]; then
        printf "${RED}Sorry. Tests for $1 isn't available yet. Consider contributing at Github.${DEFAULT}\n"
        printf "Available assignment tests: ${PURPLE}$available_assignments${DEFAULT}\n"
        exit 1
    fi
    print_footer
}

print_header()
{
    printf "${PINK}"
    space
    printf " ███▄ ▄███▓ ██▓ ███▄    █  ██▓\n"
    printf "▓██▒▀█▀ ██▒▓██▒ ██ ▀█   █ ▓██▒\n"
    printf "▓██    ▓██░▒██▒▓██  ▀█ ██▒▒██▒\n"
    printf "▒██    ▒██ ░██░▓██▒  ▐▌██▒░██░\n"
    printf "▒██▒   ░██▒░██░▒██░   ▓██░░██░\n"
    printf "░ ▒░   ░  ░░▓  ░ ▒░   ▒ ▒ ░▓  \n"
    printf "░  ░      ░ ▒ ░░ ░░   ░ ▒░ ▒ ░\n"
    printf "░      ░    ▒ ░   ░   ░ ░  ▒ ░\n"
    printf "       ░    ░           ░  ░  \n"
    printf "${DEFAULT}"
    printf "${BLUE}Mini moulinette ${DEFAULT}version 0.1.0. 2023.\n"
    space
}

print_collected_files()
{
    printf "Collected files:\n"
    ls ../* | grep -v "../41test:*" | grep -v "../41test" | column
}

space()
{
    printf "\n"
}

print_test_result()
{
    if [ $index -gt 0 ]; then
        result+=", "
    fi
    if [ $score_false = 0 ]; then
        result+="${GREEN}$assignment_name: OK${DEFAULT}"
        printf "${BG_GREEN}${BLACK}${BOLD} PASS ${DEFAULT}${PURPLE} $assignment_name/${DEFAULT}$test_name\n"
    else
        result+="${RED}$assignment_name: KO${DEFAULT}"
        printf "${BG_RED}${BOLD} FAIL ${DEFAULT}${PURPLE} $assignment_name/${DEFAULT}$test_name\n"
    fi
    if [ $break_score = 0 ]; then
        marks=$((marks+1))
    fi
}

print_footer()
{
    printf "${PURPLE}-----------------------------------${DEFAULT}\n"
    space
    PERCENT=$((100 * marks / questions))
    #printf "Total checks:  ""${GREEN}${passed} passed  ${DEFAULT} ""${checks} total"
    printf "Result:        ${result}\n"
    if [ $PERCENT -ge 50 ]; then
        printf "Final score:   ""${GREEN}$(echo $PERCENT | bc)/100${DEFAULT}\n"
        printf "Status:        ""${GREEN}passed${DEFAULT}\n"
    else
        printf "Final score:   ""${RED}$(echo $PERCENT | bc)/100${DEFAULT}\n"
        printf "Status:        ""${RED}FAILED${DEFAULT}\n"
    fi
    printf "${GREY}Test completed.\n"
    space
}

#set_test_data()
# {
#    test_data=$(echo "$assignment_data" | jq '.tests[] | select(.name == "'"$test_name"'")')
#    test_error=$(echo "$test_data" | jq -r '.error')
#}


check_dependency()
{
    if ! command -v jq &> /dev/null; then
        printf "jq is not installed. To install:\n"
        printf "  Ubuntu/Debian:\n"
        printf "    sudo apt-get update\n"
        printf "    sudo apt-get install jq\n"
        printf "  macOS/Homebrew:\n"
        printf "    brew install jq\n"
    fi
}

#check_dependency
if [ "${1}" = "" ]; then
    printf "Please select an assignment. e.g. './test.sh C01'\n"
    exit 1
fi
if [ "${1}" = "C00" -o "${1}" = "C01" -o "${1}" = "C02" -o "${1}" = "C03" -o "${1}" = "C04" -o "${1}" = "C05" -o "${1}" = "C06" -o "${1}" = "C07" -o "${1}" = "C08" -o "${1}" = "C09" -o "${1}" = "C10" -o "${1}" = "C11" -o "${1}" = "C12" -o "${1}" = "C13" ]; then
    main "$@"
    printf "$DEFAULT"
    exit
else
    printf "${RED}Invalid argument. Please select between C00 to C13${DEFAULT}\n"
fi
