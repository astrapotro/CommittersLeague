#!/bin/bash

show_title() {
    cat << "EOF"
                                         __    __                          
                                      __/\ \__/\ \__                       
  ___    ___     ___ ___     ___ ___ /\_\ \ ,_\ \ ,_\    __   _ __   ____  
 /'___\ / __`\ /' __` __`\ /' __` __`\/\ \ \ \/\ \ \/  /'__`\/\`'__\/',__\ 
/\ \__//\ \L\ \/\ \/\ \/\ \/\ \/\ \/\ \ \ \ \ \_\ \ \_/\  __/\ \ \//\__, `\
\ \____\ \____/\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \__\\ \__\ \____\\ \_\\/\____/
 \/____/\/___/  \/_/\/_/\/_/\/_/\/_/\/_/\/_/\/__/ \/__/\/____/ \/_/ \/___/ 
                                                                           
                                                                           
 __                                                                        
/\ \                                                                       
\ \ \         __     __       __   __  __     __                           
 \ \ \  __  /'__`\ /'__`\   /'_ `\/\ \/\ \  /'__`\                         
  \ \ \L\ \/\  __//\ \L\.\_/\ \L\ \ \ \_\ \/\  __/                         
   \ \____/\ \____\ \__/.\_\ \____ \ \____/\ \____\                        
    \/___/  \/____/\/__/\/_/\/___L\ \/___/  \/____/                        
                              /\____/                                      
                              \_/__/                                       

EOF
}

show_title

# This script is the Committers League. It's shows a classification of committers ordered by number, searching for git repos in a given folder
if [ $# -eq 0 ]; then
  echo "Sintax: ./committersLeague.sh <path>"
  echo "Example: ./committersLeague.sh /develop/projects/opendata/"
  exit 1
fi

monthly_date=$(date --date="1 month ago" +"%Y-%m-%d")
anual_date=$(date --date="1 year ago" +"%Y-%m-%d")
always="1979-01-01"

generate_classification() {
    path=$1 
    range=$2 
    description=$3

#    echo "$path;$range;$description"

    # Buscar los repositorios
    find -L "$path" -type d -name '.git' ! -path '*canary*' -exec bash -c '
        repo=$(dirname "$(realpath {})")
	export range="$1"
#        echo "RANGE: $range"
        if [ -d "$repo" ]; then
	    cd "$repo"
            branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)        
            echo -e "\n\n\033[96m===================== $repo ($branch) =====================\033[0m"
            git log --pretty="%ae" --since="$range"  | sort | uniq -c | sort -rn | awk "
                NR==1 {print \"\033[93m\" \$0 \"\033[0m\"; next}
                NR==2 {print \"\033[37m\" \$0 \"\033[0m\"; next}
                NR==3 {print \"\033[33m\" \$0 \"\033[0m\"; next}
                {print \$0}
            "
        fi
    ' bash "$range" {} \;

        # Generación de la clasificación total
	echo -e "\n\n\033[96m===================> TOTAL \033[94m\033[1m$3\033[0m \033[96mCLASSIFICATION in \033[94m\033[1m$1\033[0m \033[96m <====================\033\n"
        # Recopilamos y ordenamos toda la salida de los logs
        total_log=$(find -L $path -type d -name '.git' ! -path '*canary*' -exec bash -c 'export range="$1" && cd $(dirname "$(realpath {})") && git log --pretty="%ae" --since="$range"' bash "$range" {} \;)
        # Procesamos la salida total
        echo "$total_log" | sort | uniq -c | sort -rn | head -n 15 | awk '
	NR==1 {printf "\033[93m%-60s\033[0m\t🥇 🏆\n", $0; next}
	NR==2 {printf "\033[37m%-60s\033[0m\t🥈\n", $0; next}
	NR==3 {printf "\033[33m%-60s\033[0m\t🥉\n", $0; next}
	{printf "%-60s\n", $0}
	'
	echo -e "\n\033[96m=======================================================================================================\033[96m\n"
}

    echo -e ""
    echo "1 - Last month"
    echo "2 - Last year"
    echo "3 - All time"
    echo "4 - Quit"
    read -rp "Select an option: " option
    
    if [[ "$option" == "4" || "$option" == "q" ]]; then
        echo "Exiting..."
        break
    fi

    case $option in
        1)
            generate_classification "$1" "$monthly_date" "Last month"
            ;;
        2)
            generate_classification "$1" "$anual_date" "Last year"
            ;;
        3)
            generate_classification "$1" "$always" "All time"
            ;;
        *)
            echo "Option not valid."
            ;;
    esac

