// Program: String1.s
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023

.data
.global options
.text

options:
//==================================================//
// Function: AddString
addString:
    str LR, [SP, #-16]!     // Store linker

    getStringOption:
    // Prompt user
    ldr x0, =szInputOption2     // Load Address
    bl putstring                // Print

    // Get input from user
    bl clearBuffer              // Clear input buffer
    ldr x0, =kbBuf              // Allocate an output for the string
    mov x1, MAXBYTES            // Associate storage size for getstring
    bl getstring                // Get user input

    ldr x0, =kbBuf              // Load address buffer from user
    ldr x0, [x0]                // Load value entered
    // Check if valid option (a or b)
    cmp x0, #97                 // If 'a'
    B.EQ appendStringOption     // then Invalid
    cmp x0, #98                 // If 'b''
    B.EQ appendFileOption       // then Invalid

    ldr x0, =szInvalidOption    // Load address
    bl putstring                // Print Invalid Option Prompt
    B getStringOption           // Keep Looping

    addStringEnd:
        ldr LR, [SP], #16       // Load return location
        RET                     // Return

    appendStringOption:
        bl clearBuffer          // Clear buffer
        ldr x0, =szInputString  // Load prompt address
        bl putstring            // Print string
        ldr x0, =kbBuf          // Allocate an output for the string
        mov x1, MAXBYTES        // Associate storage size for getstring
        bl getstring            // Get user input

        ldr x0, =kbBuf          // Load string data
        BL appendString         // Call append string function, using x0 as string param
        B addStringEnd          // End function

    appendFileOption:
        // Get file input from user
        ldr x0, =szFileInput        // Load Prompt
        bl putstring                // Print
        bl clearBuffer              // Clear input buffer
        ldr x0, =kbBuf              // Allocate an output for the string
        mov x1, MAXBYTES            // Associate storage size for getstring
        bl getstring                // Get user input

        ldr x0, =kbBuf              // Load input buffer (the file location)
        bl appendFileContents       // Passes x0 as a param to get x0 as the file contents

        B addStringEnd              // End function
