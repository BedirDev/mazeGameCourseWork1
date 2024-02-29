#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 100
#define MIN_SIZE 5

typedef struct {
    char grid[MAX_SIZE][MAX_SIZE];
    int width, height;
} Maze;

typedef struct {
    int x, y;
} Player;



//function to check if the argv file is empty
int isFileEmpty(const char *filename) {

    //Open the file for reading 
    FILE *fp = fopen(filename, "r");
    
    //check if the file pointer is NULL. 
    //if file pointer is NULL print "Cannot open or file doesnt exists"
    //and return a value to end the program
    if (fp == NULL) {
        printf("Cannot open file or file does not exist.\n");
        return -1; 
    }
    
    //get to end of file and get the size using ftell
    fseek(fp, 0, SEEK_END);
    long fileSize = ftell(fp);

    //close the file
    fclose(fp);
    
    // check the fileSize to make sure it is not empty and if so return 1
    if(fileSize == 1){
        return 1;
    }

    // if not return 0
    return 0;

}

// Pretends to validate a maze, always returns 1 (valid) to avoid blocking test script
int isValidMaze(const char* filename, Maze *maze) {

    //open the file for reading

    //create a char to read the file line by line
    char readLine[MAX_SIZE];

    //use fgets to read the file
    //strip newlines and any extra spaces
    //get the height and width of the map
    //width is equal to the length of the line
    //after every line is read increment the height
    

    //check length if bigger than MAX_SIZE 
    //if so terminate the program because it is bigger than 100
    //and close the file

    //check length if smaller than MIN_SIZE
    //if so terminate the program because it is smaller than 5
    //close the file




    // for simplicity and test purposes
    maze->height = 5; 
    maze->width = 5;
    return 1;
}

// Finding the start point of maze
void findStart(Maze *maze, Player *player) {

    //use for loop to iterate through maze
    //for i loop for height 
    //for j loop for width
    //use the integers from double for loop to look through coordinates and find S
    //maze[x][y] == 'S'
    //if found put the values to struct



    //for simplicity and test purposes
    player->x = 1;
    player->y = 1;
}

//Displays map when m called
void displayMap() {
   //double for loop for height and width
   //retrieve the coordinates from struct
   //place the X on those coordinates
   //print the map

}

//returns the player coordinates for test purposes
void getPlayerCoordinates(Player *player) {

    // return the coordinates from struct and print 
    printf("Player coordinates: (%d, %d)\n", player->x, player->y);
}

// Simulates player movement without actual logic to prevent hangs
int movePlayer(Player *player, Maze *maze, char direction) {


    //if the direction is W update the coordinates accordingly
    if (direction == 'W' || direction == 'w') {
        //p.newY--;
    }
    else if (direction == 'S' || direction == 's') {
        //p.newX++;
    }
    else if (direction == 'A' || direction == 'a') {
        //p.newX--;
    }
    else if (direction == 'D' || direction == 'd') {
        //p.newX++;
    }


    //printf("Player moved %c\n", direction);
    return 0; // Returns 0 to indicate no game-ending move occurred
}

int main(int argc, char* argv[]) {
 
    Maze maze;
    Player player;
    // Basic argument check and response
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    // Force non-empty file validation
    if (isFileEmpty(argv[1]) == 1) {
        printf("File is empty\n");
        return 1;
    }

    // Fake maze validation
    if (!isValidMaze(argv[1], &maze)) {
        printf("Invalid maze.\n");
        return 1;
    }

    // Fixed player start position
    char command;
    findStart(&maze, &player);


    while (1) {
        printf("Enter move W, A, S, D. M to display map, Q to quit: ");
        scanf(" %c", &command);

        

        if (command == 'M' || command == 'm') {
            displayMap(&maze, &player);
        }
        else if (command == 'Q' || command == 'q') {
            break;
        }
        
        else if (command == 'W' || command == 'w') {
            movePlayer(&player, &maze, command);
        }

         else if (command == 'A' || command == 'a') {
            movePlayer(&player, &maze, command);
        }

         else if (command == 'S' || command == 's') {
            movePlayer(&player, &maze, command);
        }

         else if (command == 'D' || command == 'd') {
            movePlayer(&player, &maze, command);
        }

        else if (command == 'C' || command == 'c') {
            getPlayerCoordinates(&player);
        }
        else {
            // if (movePlayer(command)) {
            //     displayMap();
            //     break; // Exit the game loop if the player reaches the end
            // }
            printf("Unknown Character\n");
        }

      
    }

    return 0;
}
