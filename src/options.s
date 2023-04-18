// Program: String1.s
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023

// FILE MODES
.equ	R,	00 		// read only
.equ 	W,	01 		// write only
.equ 	RW, 	02 		// read write
.equ 	T_RW, 	01002 		// truncate read write
.equ 	C_W, 	0101 		// create file if does not exist
.equ 	CREATEWOT, 01101 	// create if file does not exist for writing
.equ    APPEND_CR, 02102    // Append, Read, Create
.equ    TRUNCATE,  01102

// FILE PERMISSIONS
.equ 	RW_RW___, 0644
.equ 	CURRNDIR, -100

.data
.global options
.text

options:
//==================================================//
// Function: AddString [2]
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

    // Print invalid option and keep looping
    ldr x0, =szInvalidOption    // Load address
    bl putstring                // Print Invalid Option Prompt
    B getStringOption           // Keep Looping

    appendStringOption:
        ldr x0, =szInputString  // Load prompt address
        bl putstring            // Print string
        bl clearBuffer          // Clear buffer
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

    addStringEnd:
        ldr LR, [SP], #16       // Load return location
        RET                     // Return

//==================================================//
// Function: deleteString [3]
deleteString:
    str LR, [SP, #-16]!         // Store linker

    // Get user to enter index
    ldr x0, =szEnterIndex       // Load address
    bl putstring                // Prompt user
    bl clearBuffer              // Clear input buffer
    ldr x0, =kbBuf              // Allocate an output for the string
    mov x1, MAXBYTES            // Associate storage size for getstring
    bl getstring                // Get user input

    // Get index as int
    ldr x0, =kbBuf              // Get buffer
    bl ascint64                 // Get value as int into x0

    // Call Delete
    bl deleteIndex              // Calls to delete an index. Returns in x0 if successful

    // Print
    cmp x0, #1                  // If successful
    B.EQ deleteSuccess          // Print success

    ldr x0, =szInvalidIndex     // Load address
    bl putstring                // Print invalid index
    B deleteStringEnd           // End

    deleteSuccess:
    ldr x0, =szDeleteSuccess    // Load address
    bl putstring                // Print successful delete

    deleteStringEnd:
    ldr LR, [SP], #16           // Load return location
    RET                         // Return

//==================================================//
// Function: editString [4]
editStringOption:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!        // Preserve
    str x21, [SP, #-16]!        // Preserve
    str x22, [SP, #-16]!        // Preserve
    str x23, [SP, #-16]!        // Preserve
    str x24, [SP, #-16]!        // Preserve

    // Get user to enter index
    ldr x0, =szEnterIndex       // Load address
    bl putstring                // Prompt user
    bl clearBuffer              // Clear input buffer
    ldr x0, =kbBuf              // Allocate an output for the string
    mov x1, MAXBYTES            // Associate storage size for getstring
    bl getstring                // Get user input

    // Get index as int
    ldr x0, =kbBuf              // Get buffer
    bl ascint64                 // Get value as int into x0
    bl editString               // replaces element at defined index


    editStringEnd:
    mov x0, #0
    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function: searchString [5]
searchStringOption:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x21, [SP, #-16]!    // Preserve
    str x22, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve
    str x24, [SP, #-16]!    // Preserve
    str x27, [SP, #-16]!    // Preserve

    ldr x0, =szInputSearch  // Load prompt
    bl  putstring           // Print to terminal

    // Get input string to search for
    bl clearBuffer              // Clear input buffer
    ldr x0, =kbBuf              // Allocate an output for the string
    mov x1, MAXBYTES            // Associate storage size for getstring
    bl getstring                // Get user input

    // Print hits text
    ldr x0, =szNotePad1         // Load address
    bl putstring                // Print 

    ldr x0, =chQuote            // Load address
    bl putch                    // Print "

    // Print string
    ldr x0, =kbBuf              // Load address
    bl putstring

    ldr x0, =chQuote            // Load address
    bl putch                    // Print "

    // Print hits text 2
    ldr x0, =szNotePad2
    bl putstring

    // Search the linked list
    ldr x0, =kbBuf              // Get buffer
    mov x1, #0
    bl searchString             // Returns the number of occurances in x0
    mov x21, x1                 // Saves total transversed

    // Print hits
    ldr x1, =szBuffer   	    // int64asc stores the result in a pointer
    bl int64asc         	    // Converts the int in x0 to ascii for printing
    ldr x0, =szBuffer   	    // Gets the value returned from int64asc
    bl putstring                // Print int

    // Print hits text 3
    ldr x0, =szNotePad3
    bl putstring

    // Print number transversed
    mov x0, x21
    ldr x1, =szBuffer   	    // int64asc stores the result in a pointer
    bl int64asc         	    // Converts the int in x0 to ascii for printing
    ldr x0, =szBuffer   	    // Gets the value returned from int64asc
    bl putstring                // Print int

    // Print hits text 4
    ldr x0, =szNotePad4
    bl putstring

    // Search the linked list and print
    ldr x0, =kbBuf              // Get buffer
    mov x1, #1                  // Set print = True
    bl searchString             // Params: x0 = String



    mov x0, #0
    ldr x27, [SP], #16      // Preserve
    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function: saveFile [6]
saveFile:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x21, [SP, #-16]!    // Preserve
    str x22, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve

    //find and open text file inputted by user
    ldr x0, =szFileInput        // Load Prompt
    bl putstring                // Print
    bl clearBuffer              // Clear input buffer
    ldr x0, =kbBuf              // Allocate an output for the string
    mov x1, MAXBYTES            // Associate storage size for getstring
    bl getstring                // Get user input

    // ==================== Opening/creating file ===================
    // open output file and truncate
    mov	x0, #CURRNDIR		//special current directory number
    ldr x1, =kbBuf          // Load input buffer (the file location)
    mov	x2, #TRUNCATE 		//FLAGS
    mov	x3, #RW_RW___ 		//MODE
    mov x8, 0x38 		    //open
    svc 0 			        //returns file descriptor in x0

    cmp x0, #0              // If error opening file
    B.EQ endSaveFile        // Exit

    mov X8, #57 	        // Close file
    svc 0			        // Execute syscall

    // ==================== Opening/creating file ===================
    // open output file and append
    mov	x0, #CURRNDIR		//special current directory number
    ldr x1, =kbBuf          // Load input buffer (the file location)
    mov	x2, #APPEND_CR 		// FLAGS
    mov	x3, #RW_RW___ 		// MODE
    mov x8, 0x38 		    // open
    svc 0 			        // returns file descriptor in x0
    mov x20, x0             // Save file descriptor 

    cmp x0, #0              // If error opening file
    B.EQ endSaveFile        // Exit

    // ==================== Writing to file =========================
    // x0 already has file descriptor from openat syscall
    // Begin Loop
    ldr x0, =headPtr        // Load address
    ldr x0, [x0]            // Load malloc address of the first node
    cmp x0, #0              // If first node is null..
    B.EQ endSaveFile        // Print an error
    ldr x0, =headPtr        // get node address
    ldr x22, [x0]           // Load the malloc address

loopLL:
    // Load next node
    ldr x21, [x22, #8]      // Load last 8 bytes (node address)

    // Get length of string
    ldr x0, [x22]           // Load string address
    bl String_length        // Get string length into x0
    mov x2, x0              // Move to x2

    // Print String to File
    mov x0, x20             // Get file descriptor
    ldr x1, [x22]           // Load string address
    mov x8, #64 		    // Write
    svc 0			        // Call Syscall

    cmp x21, #0             // if next pointer is null.. end loop
    B.EQ endSaveFile        // End Loop

    // Print New Line to File
    mov x0, x20             // Get file descriptor
    ldr x1, =szNewLine      // Get New Line string
    mov x2, #1              // Set length to 1
    mov x8, #64 		    // Write
    svc 0                   // Call Syscall

    mov x22, x21            // Move next node to current
    b   loopLL              // Keep Looping

    endSaveFile:
    // Close File
    mov x0, x20             // Get file descriptor
    mov X8, #57 	        // Close file
    svc 0			        // Execute syscall

    mov x0, #0              // exit status code

    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return
    