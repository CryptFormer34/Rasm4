// Program: Rasm4.s
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023
// https://online.saddleback.edu/courses/8887/assignments/247510
	.global _start
    .equ MAXBYTES, 1024
	.data 

szPrint1:       .asciz "\n\t\tRASM4 TEXT EDITOR\n\tData Structure Heap Memory Consumption: "
szPrint2:       .asciz " bytes"
szPrint3:       .asciz "\n\tNumber of Nodes: "
szOptions:      .asciz "<1> View all strings\n\n<2> Add string\n\t<a> from Keyboard\n\t<b> from File.\n\n<3> Delete string. Given an index #, delete the entire string and de-allocate memory (including the node).\n\n<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.\n\n<5> String search. Regardless of case, return all strings that match the substring given.\n\n<6> Save File\n\n<7> Quit"

szInputOption1: .asciz "Enter Option (0-7): "
szInputOption2: .asciz "Enter Option (a or b): "
szInputString:  .asciz "Enter String: "
strError:       .asciz "No data in linked list to print\n" //Todo: Remove
szInvalidOption:.asciz "Invalid option selected.\n"
szPrintResult:  .asciz "\nStrings:\n"
szFileInput:    .asciz "Enter filename: "

kbBuf:          .skip MAXBYTES
szBuffer:       .skip 16    // Small operations such as converting to ascii or int
chCr: 		    .byte 10    // new line
chSpace:        .byte 32    // Space
chLeftB:        .byte 91    // [
chRightB:       .byte 93    // ]       

headPtr:        .quad  0    // Start of linked list
tailPtr:        .quad  0    // Not sure what this is for
strPtr:         .quad  0    // Todo: refactor this
newNodePtr:     .quad  0    // Temp pointer to a new node
iMemoryBytes:   .quad  0    // Total number of bytes being malloc'd
iNumNodes:      .quad  0    // Number of nodes in the linked list

    .text
_start: 
//========================================//

    BL promptOptions            // Prints options to the user; returns result in x0

    // View All Strings
    cmp x0, #1                  // If option != 1
    B.NE skipOption1            // Skip
    BL printLinkedList          // Else: Preform Option
    skipOption1:

    // Add String
    cmp x0, #2                  // If option != 2
    B.NE skipOption2            // Skip
    B addString                 // Else: Preform Option
    skipOption2:

    // Delete string
    cmp x0, #3                  // If option != 3
    B.NE skipOption3            // Skip
    B end                       // Else: Preform Option
    skipOption3:

    // Edit string
    cmp x0, #4                  // If option != 4
    B.NE skipOption4            // Skip
    B end                       // Else: Preform Option
    skipOption4:

    // String search
    cmp x0, #5                  // If option != 5
    B.NE skipOption5            // Skip
    B end                       // Else: Preform Option
    skipOption5:

    cmp x0, #6                  // If option != 6
    B.NE skipOption6            // Skip
    B end                       // Else: Preform Option
    skipOption6:

    cmp x0, #7                  // If option != 7
    B.NE skipOption7            // Skip
    B end                       // Else: Preform Option
    skipOption7:

    B _start

//========================================//
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

        B addStringEnd          // End function

//========================================//
    // Function: promptOptions
promptOptions:
    str LR, [SP, #-16]!     // Store linker
    ldr x0, =szPrint1       // Load #1 header
    bl putstring            // Print

    ldr x0, =szPrint2       // Load #2 header
    bl putstring            // Print

    ldr x0, =szPrint3       // Load #3 header
    bl putstring            // Print

    ldr x0, =chCr           // Load new line
    bl putch                // Print

    ldr x0, =szOptions      // Load list of options
    bl putstring            // Print options

    ldr x0, =chCr           // Load new line
    bl putch                // Print

    getOption:
    // Prompt user
    ldr x0, =szInputOption1 // Load Address
    bl putstring            // Print

    // Get input from user
    bl clearBuffer          // Clear buffer
    ldr x0, =kbBuf          // Allocate an output for the string
    mov x1, MAXBYTES        // Associate storage size for getstring
    bl getstring            // Get user input

    ldr x0, =kbBuf          // Load address buffer from user
    ldr x0, [x0]            // Load value entered
    // Check if valid option (1 - 7)
    cmp x0, #49             // If < 0
    B.LT invalidOption      // then Invalid
    cmp x0, #55             // If > 7
    B.GT invalidOption      // then Invalid

    B optionOkay            // Skip over invalid option

    invalidOption:
        ldr x0, =szInvalidOption    // Load address
        bl putstring        // Print Invalid Option Prompt
        B getOption         // Loop back and ask for proper option

    optionOkay:
    ldr x0, =kbBuf          // Get address
    bl ascint64             // Converts x0 to int from ascii
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//========================================//
// Clear buffer
clearBuffer:
    str LR, [SP, #-16]!     // Store linker

    ldr x0, =kbBuf
    mov x1, #0             // 0 value
    mov x2, #0             // Index

    clearBufferLoop:
        strb w1, [x0, x2]    // Store null value
        add x2, x2, #1        // Increment Index
        cmp x2, MAXBYTES
        B.EQ endLoop
        B clearBufferLoop

    endLoop:
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//========================================//
// Print index
// Params: x0 (int)
// Returns: None
printIndex:
    str LR, [SP, #-16]!     // Store linker
    str x19, [SP, #-16]!    // Preserve
    str x1, [SP, #-16]!     // Preserve

    mov x19, x0             // Copy over

    ldr x0, =chLeftB        // [
    bl putch                // Print

    mov x0, x19             // Copy back
    ldr x1, =szBuffer       // int64asc stores the result in a pointer in register 1
    bl int64asc             // Converts the int in x0 to ascii for printing
    ldr x0, =szBuffer       // Gets the value returned from int64asc
    bl putstring            // Print int

    ldr x0, =chRightB       // ]
    bl putch                // Print

    ldr x0, =chSpace        // Store space
    bl putch                // Print

    ldr x1, [SP], #16       // Preserve
    ldr x19, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//========================================//
    // End Program
end:
    bl freeLinkedList       // Free Memory
    mov     x0, #0          // Store array for debugging
    mov     X8, #93         // Service code 93 terminates
    svc     0               // Call Linux to terminate
    .end