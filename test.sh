#!/bin/bash
gcc code.c -o maze


# Function to test a movement command and its expected output messages
playerMovementCoordinateTest() {
    command=$1
    #deletes the first parameter
    shift 
    expected_messages=("$@") #the rest of the parameters
    match=0

    # sending command to program and reading the output
    output=$(echo -e "${command}\nc\nQ" | ./maze validMazes/map_5x5.txt)

    # Loop through each expected message
    for expected_message in "${expected_messages[@]}"; do
        # Check if the output contains the  expected message
        if echo "$output" | grep -Fq -- "$expected_message"; then
            match=1
            #store the string
            matching_string="$expected_message" 
            break
        fi
    done

    if [[ $match == 1 ]]; 
    then
        if [ "$matching_string" = "Invalid move." ]; 
            then
                echo "${command}: PASS"
            else
                echo "${command}: PASS"
        fi
    else
        echo "${command}: FAIL"
    fi
}

#this function is used to convert navigation files into one string command for example: d\nd\nd\nM\nQ
read_file_and_convert_to_string() {
    file="$1"
    stringCommand=$""
    
    #read the file and put new line between every line
    while IFS= read -r line || [[ -n $line ]];
    do
        stringCommand+="$line"$'\n'  
    done < "$file"

    # Append "Q" at the end
    stringCommand+="Q"

    echo "$stringCommand"
}









#TESTING IF THE PROGRAM CAN DETECT INVALID MAZES.
echo "TEST INVALID MAP"


outputInvalidMaze=$(echo q | ./maze invalidMazes/invalidMap.txt)

#echo $outputCorrectMaze
if [[ $outputInvalidMaze == *"Invalid maze"* ]]; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"

##TESTING VALID MAZE
echo "TEST VALID MAZE"

outputValidMaze=$(echo q | ./maze validMazes/map_5x5.txt) 

#echo $outputValidMaze
#if the output doesnt contain "Invalid maze" then the map is valid
if [[ $outputValidMaze != *"Invalid maze"* ]]; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"


#TESTING MISSING MAP FILE
echo "TEST MISSING MAP FILE"
outputMissingFile=$(./maze)

#the output of a missing file will be, Usage: ./maze <filename>. And as we are not doing an exact comparison of strings searching for "Usage will enough"
if echo $outputMissingFile | grep -q "Usage:";
    then
        echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"


#TESTING TOO SMALL FILE
echo "TESTING A SMALL 4x3 FILE"
outputSmallFile=$(echo Q |./maze invalidMazes/tooSmallMap.txt)

if echo $outputSmallFile | grep -q "Invalid maze: size out of bounds.";
    then 
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"

#TEST input q QUITS THE PROGRAM
echo "TEST QUIT"

#we are expecting no return so just empty quotes
playerMovementCoordinateTest "q" ""

echo -e "=====================================================================\n"

#TEST SPECIAL CHARACTERS
#This test is adapted from chatGPT’s response to the prompt "what are special characters"
playerMovementCoordinateTest "\033" "Unknown Character"

echo -e "=====================================================================\n"

#TEST EMOJIS 💪🏻
echo "TEST EMOJIS"
playerMovementCoordinateTest "💪🏻" "Unknown Character"

echo -e "=====================================================================\n"

#TEST TWO FILE INPUTS
echo "TEST TWO FILE INPUT"

#in this the program will always open the first file input and we want to check if the correct file has been uploaded
outputTwoFileInput=$(echo m\nQ | ./maze validMazes/map_5x5.txt validMazes/map_9x6.txt) 

# we have sent 'm' command to fetch the map. now we are going to compare if returned map is same as the uploaded one
#in this code we are getting all the chrachters between the first and last #
filterOutputTwoFileInput=$(echo "$outputTwoFileInput" | grep -o '#.*#')

#our map we upload and the map in the game is slightly different. In the game there is X on the start point. in the text file there is S and no X
#so here we change the X with S from the output we got from game after inputting M
filterOutputTwoFileInput="${filterOutputTwoFileInput//X/S}"

#using this function not specifically designed for this proccess but for another test below
#the function is satisfactory to use for this test as it read the file and converts it to a string
stringMap_5x5=$(read_file_and_convert_to_string "validMazes/map_5x5.txt")

# as we are using a function designed for similar thing, the function adds Q at the end of the string and here we are removing that char
stringMap_5x5="${stringMap_5x5//Q/}"


#This test is adapted from chatGPT’s response to the prompt "How to use sed emptyline removal for variables?"
filterOutputTwoFileInput=$(echo "$filterOutputTwoFileInput" | sed '/^$/d')
stringMap_5x5=$(echo "$stringMap_5x5" | sed '/^$/d')

echo "$filterOutputTwoFileInput" > tmp1.txt
echo "$stringMap_5x5" > tmp2.txt

if diff -q tmp1.txt tmp2.txt > /dev/null; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

#remove the text file that were created for comparison
rm "tmp1.txt" "tmp2.txt"


echo -e "=====================================================================\n"


#TEST IF MAP SHOWING WHEN M/m clicked
echo "TEST input M\m"

#almost identical "TEST TWO FILE INPUT". However, they serve different reasons
outputMap=$(echo "m\nQ" | ./maze validMazes/map_5x5.txt) 
filterOutputMap=$(echo "$outputMap" | grep -o '#.*#')
filterOutputMap="${filterOutputMap//X/S}"

stringMap=$(read_file_and_convert_to_string "validMazes/map_5x5.txt")
stringMap="${stringMap//Q/}"

filterOutputMap=$(echo "$filterOutputMap" | sed '/^$/d')
stringMap=$(echo "$stringMap" | sed '/^$/d')

echo "$filterOutputMap" > tmp1.txt
echo "$stringMap" > tmp2.txt

if diff -q tmp1.txt tmp2.txt > /dev/null; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi
#remove the text file that were created for comparison
rm "tmp1.txt" "tmp2.txt"


echo -e "=====================================================================\n"


#TEST IF THE S occurs more than once
echo "TEST S OCCURENCE"

#read the output from file for command m
outputMapS=$(echo "m\nQ" | ./maze validMazes/map_5x5.txt )
outputMapS=$(echo "$outputMapS" | grep -o '#.*#') #get the map

outputMapS="${outputMapS//X/S}" #change user location to start. we didnt make any moves so x is where the start is

#get the number of Ss in the map
count_s=$(echo -n "$outputMapS" | tr -cd 'S' | wc -c)

#check how many times the s was occured
if [[ $count_s == 1 ]];
    then    
        echo -e "PASS\n"
else
    echo -e "FAIL\n"

fi

echo -e "=====================================================================\n"


#TEST IF THE X occurs more than once
echo "TEST X OCCURENCE"

#read the output from file for command m
outputMapX=$(echo "m\nQ" | ./maze validMazes/map_5x5.txt )
outputMapX=$(echo "$outputMapX" | grep -o '#.*#') #to get the exact map

#get the number of Xs in the map
count_X=$(echo -n "$outputMapX" | tr -cd 'X' | wc -c)

#check how many times the X was occured
if [[ $count_X == 1 ]];
    then    
        echo -e "PASS\n"
else
    echo -e "FAIL\n"

fi

echo -e "=====================================================================\n"

#TEST EMPTY MAP FILE
echo "TEST EMPTY MAP FILE"
outputEmptyMaze=$(echo q | ./maze invalidMazes/emptyMaze.txt) 

#if the output doesnt contain "Invalid maze" then the map is valid
if [[ $outputEmptyMaze == *"File is empty"* ]]; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi


echo -e "=====================================================================\n"

#TESTING THE PLAYER'S MOVEMENT
echo "TESTING MOVEMENTS"
# Test each movement command with multiple possible expected outputs
playerMovementCoordinateTest "w" "Player coordinates: (1, 0)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "a" "Player coordinates: (0, 1)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "s" "Player coordinates: (1, 2)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "d" "Player coordinates: (2, 1)" "Invalid move." "Game Over. You won."

echo -e "=====================================================================\n"

#TESTING THE PLAYER MOVEMENTS WITH CAPITAL LETTERS
echo "TESTING CAPITAL LETTERS"
playerMovementCoordinateTest "W" "Player coordinates: (1, 0)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "A" "Player coordinates: (0, 1)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "S" "Player coordinates: (1, 2)" "Invalid move." "Game Over. You won."
playerMovementCoordinateTest "D" "Player coordinates: (2, 1)" "Invalid move." "Game Over. You won."

echo -e "=====================================================================\n"


# TEST UNKNOWN CHARACTER
echo "TEST UNKNOWN CHARACTER"
playerMovementCoordinateTest "k" "Unknown Character"

echo -e "=====================================================================\n"

#CHECKING FOR INVALID MOVES SUCH AS WALL
echo "TEST HITTING THE WALL"
playerMovementCoordinateTest "w" "Invalid move."

echo -e "=====================================================================\n"

#TESTING A NUMBER AS INPUT
echo "TEST INPUTTING A NUMBER"
playerMovementCoordinateTest "1" "Unknown Character"

echo -e "=====================================================================\n"

#TESTING WITH A LARGE INPUT
echo "TESTING WITH A LARGE INPUT"
#here we are looking for 'e' because 
playerMovementCoordinateTest "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" "Unknown Character"

echo -e "=====================================================================\n"

#CHECKING FOR INVALID MOVES SUCH AS REACHING THE LIMIT OF THE MAP
#map file is taken from student_maps provided by AMY BRERETON
echo "MAP LIMIT TEST"
if echo "d\nd\nd\nd\nd\nd\nd\nd\nd\nQ" | ./maze reg_10x6.txt | grep -q "Invalid move"; then
    echo -e "PASS\n"
else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"

#Test the player starts in start not in a wall.
#for that we can use coordinates again and if either x or y is equal to 0 it means the player is in a wall
#we get the coordinates from the program by inputting C and our output should be Player coordinates: (x, y). 
#then we get the chars at 22 which is x and at 25 which is y. then we check if either one of them is equal to 0, then it is a FAIL
echo "PLAYER SPAWN TEST"

outputWall=$(echo -e "C\nQ" | ./maze)

#IN THIS CODE, AS OUR COORDINATES FROM THE PROGRAM COMES IN BRACKETS, WE ARE EXTRACTING THE VALUES THAT ARE NOT IN BRACKETS
#THEN WITH TWO DIFFERENT STRING WE GET THE VALUES FOR X AND Y AXIS. IF ANY OF THEM IS 0, THAT MEANS THE PLAYER HAS SPAWNED IN A WALL
outputWallAxis=$(echo "$outputWall" | grep -o '(.*)')
outputWallAxisX="${outputWallAxis:1:1}"
outputWallAxisY="${outputWallAxis:4:1}"

if [[ "$outputWallAxisX" == "0" ]] || [[ "$outputWallAxisY" == "0" ]]; 

   then

   echo -e "FAIL\n"

else 
    echo -e "PASS\n"
fi

echo -e "=====================================================================\n"


#Test the game board initializes correctly with walls, start point and end point.
echo "TEST BOARD"
outputBoard=$(echo "m\nQ" | ./maze validMazes/map_5x5.txt)
#this code will filter the output and give us the string between first and last #
filteredOutputBoard=$(echo "$outputBoard" | grep -o '#.*#')
#echo "$filteredOutputBoard"

#now as we have the exact map values with walls, S, X, E, and empty spaces we can continue checking if the map includes all the symbols

charNumberSign="#"
charS='S'
charX='X'
charE='E'

#here we are checking if our map has the chars above. if yes than it means it is a correct map
if [[ "$filteredOutputBoard" == *"$charNumberSign"* ]] && [[ "$filteredOutputBoard" == *"$charX"* ]] && [[ "$filteredOutputBoard" == *"$charE"* ]] || [[ "$filteredOutputBoard" == *"$charS"* ]];
 then
    echo -e "PASS\n"
    else
    echo -e "FAIL\n"
fi

echo -e "=====================================================================\n"


##test if the game ends when the player reaches X
echo "TEST GAME OVER"
#now we are going to check all maps with their navigation file
#the order of the files matter in both arrays
navigation_files=("navigation_gameOver/navigation_5x5GameOver.txt" "navigation_gameOver/navigation_13x4GameOver.txt" "navigation_gameOver/navigation_9x6GameOver.txt" "navigation_gameOver/navigation_11x11GameOver.txt" "navigation_gameOver/navigation_30x20GameOver.txt" "navigation_gameOver/navigation_7x54GameOver.txt" "navigation_gameOver/navigation_61x60GameOver.txt" "navigation_gameOver/navigation_43x46GameOver.txt")
maze_files=("validMazes/map_5x5.txt" "validMazes/map_13x4.txt" "validMazes/map_9x6.txt" "validMazes/map_11x11.txt" "validMazes/map_30x20.txt" "validMazes/map_7x54.txt" "validMazes/map_61x60.txt" "validMazes/map_43x46.txt")

#These maps are adapted from chatGPT’s response to the prompt "Hi, can you please give me text based maze maps where # are walls S is start and E is the end. A maze has a height and a width, with a maximum of 100 and a minimum of 5"

# ITERATE THROUGH navigation_files with an incerement
for ((i = 0; i < ${#navigation_files[@]}; i++))
{ 
    echo "TEST[$i] - Testing file: ${navigation_files[i]}"
    
    # here we are calling the function and giving the navigation files as parameter for it to convert to string where our inputs will be
    result_string=$(read_file_and_convert_to_string "${navigation_files[i]}")

    # using the input string from the code above. Also, we are iterating through maze_files using the increment.
    output=$(echo "$result_string" | ./maze "${maze_files[i]}")
    
    #echo "RESULT STRING: $result_string"

    # the program should return "Game Over. You won" if the inputs above are correct and it reached to E
    if [[ $output == *"Game Over. You won"* ]]; then   
        echo -e "PASS\n"
    else
        echo -e "FAIL\n"


    fi

echo -e "=====================================================================\n"
}


#TEST IF WANDERING AROUND THE MAP WORKS
#this piece of code is very similar to one above and the maze_files array created for "game over" test above will be used again here
echo "TESTING RANDOM MOVEMENTS IN THE MAP"


navigation_wander_files=("navigation_gameOver/wander/navigation_5x5Wander.txt" "navigation_gameOver/wander/navigation_13x4Wander.txt" "navigation_gameOver/wander/navigation_9x6Wander.txt" "navigation_gameOver/wander/navigation_11x11Wander.txt" "navigation_gameOver/wander/navigation_30x20Wander.txt" "navigation_gameOver/wander/navigation_7x54Wander.txt" "navigation_gameOver/wander/navigation_61x60Wander.txt" "navigation_gameOver/wander/navigation_43x46Wander.txt")

for ((i = 0; i < ${#navigation_wander_files[@]}; i++))
{ 
    echo "TEST[$i] - Testing file: ${navigation_wander_files[i]}"
    
    result_string=$(read_file_and_convert_to_string "${navigation_wander_files[i]}")

    outputWander=$(echo "$result_string" | ./maze "${maze_files[i]}")

    # the program should return "Enter move W, A, S, D. M to display map, Q to quit:" Because it is the output from program asking user to input
    if [[ $outputWander == *"Enter move W, A, S, D. M to display map, Q to quit: "* ]]; then   
        echo -e "PASS\n"
    else
        echo -e "FAIL\n"
    fi

echo -e "=====================================================================\n"
}

rm maze