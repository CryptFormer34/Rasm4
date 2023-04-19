// Program: String.s
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023

.data
.global stringFunctions
.text

stringFunctions:
//==================================================//
// Function String_length
// Params:
// x0 = String Address
// Returns:
// x0 = int (word)
// Counts the number of characters.
strlength:
    str LR, [SP, #-16]!     // Store e
    // Preserve registers
    str x1, [SP, #-16]!     // Push
    str x2, [SP, #-16]!     // Push

    mov x1, #0              // Counter

    strlengthLoop:          // Begin Loop
    ldrb w2, [x0, x1]       // Read current byte in string
    cmp w2, #0              // If character is null
    B.LE strlength_Ret      // Return if null

    add x1, x1, #1          // Increment counter

    b strlengthLoop         // Keep looping

    strlength_Ret:
    mov x0, x1              // Move value into return

    // Preverse registers by reversed order
    ldr x2, [SP], #16       // POP
    ldr x1, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location

    RET                     // Return


//==================================================//
// Function String_equalsIgnoreCase
// Params:
// x0 = String Address
// x1 = String address
// Returns:
// x0 = bool (byte)
// Compares if characters are equal and ignores case 
// (characters and length are the same)
String_equalsIgnoreCase:
    str LR, [SP, #-16]!     // Store linker
    // Preserve registers
    str x2, [SP, #-16]!     // Push
    str x3, [SP, #-16]!     // Push

    bl String_copy          // Copies x0 string
    bl String_toLowerCase   // Convert x0 to lower
    mov x2, x0              // Temp swap register

    mov x0, x1              // Move 2nd string into x0
    bl String_copy          // Copies x0 string
    bl String_toLowerCase   // Convert x0 to lower
    mov x1, x0              // Move string back to x1
    mov x3, x0              // Temp store register
    mov x0, x2              // Move string back to x0

    bl String_equals        // Compare if both are equal and store bool in x0
    str x0, [SP, #-16]!     // Push

    // Free memory from the copies
    mov x0, x3              // 2nd copy
    bl free                 // Free memory
    mov x0, x2              // 1st copy
    bl free                 // Free memory

    ldr x0, [SP], #16       // POP
    ldr x3, [SP], #16       // POP
    ldr x2, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function String_copy
// Params:
// x0 = String Address
// Returns:
// x0 = Address of new string
// Copies the string and allocates dynamic memory for it. Use the Alloc method
String_copy:
    str LR, [SP, #-16]!     // Store linker
    // Preserve registers
    str x1, [SP, #-16]!     // Push - Used for alloc string
    str x2, [SP, #-16]!     // Push - Used for length, current char
    str x3, [SP, #-16]!     // Push - Used for I 

    // Get length of original string
    mov x1, x0              // Store copy of string address
    bl strlength            // Gets the length, stores in x0

    // mov x29, x0
    // ldr x1, =szBuffer   	// int64asc stores the result in a pointer
    // bl int64asc         	// Converts the int in x0 to ascii for printing
    // ldr x0, =szBuffer   	// Gets the value returned from int64asc
    // bl putstring            // Print int
    // mov x0, x29

    // Dedicate Memory
    add x0, x0, #1          // Add one for the null character
    str x1, [SP, #-16]!     // Preserve
    str x2, [SP, #-16]!     // Preserve
	bl malloc               // Dedicate memory
    ldr x2, [SP], #16       // Pop
    ldr x1, [SP], #16       // Pop

    mov x3, #0              // x3: i = 0
    SC_Loop:
        ldrb w2, [x1, x3]   // Load character from original string
        cmp w2, #0          // If current char is null
        B.EQ SC_End         // End

        strb w2, [x0, x3]   // Store character into allocated string

        add x3, x3, #1      // i++
        B SC_Loop           // Keep looping

    SC_End:
    // Ensure theres null at end
    mov w2, #0              // Set null value
    strb w2, [x0, x3]       // Store at end of loop

    // Make sure to free memory later to avoid memory leak
    ldr x3, [SP], #16       // POP
    ldr x2, [SP], #16       // POP
    ldr x1, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location
    RET                     // Return
//==================================================//
// Function String_equals
// Params:
// x0 = String Address
// x1 = String address
// Returns:
// x0 = bool (byte)
// Compares if characters are equal (characters and length are the same)
String_equals:
    str LR, [SP, #-16]!     // Store linker
    // Preserve registers
    str x2, [SP, #-16]!     // Push
    str x3, [SP, #-16]!     // Push
    str x4, [SP, #-16]!     // Push

    mov x2, #0              // i = 0
    SE_Loop:
        ldrb w3, [x0, x2]       // x3 = str[i]
        ldrb w4, [x1, x2]       // x3 = str[i]

        cmp x3, #0              // If the byte is null
        B.EQ SE_True            // If true, branch to true result

        cmp x3, x4              // Compare if characters are equal
        B.NE SE_False           // Jump to false

        add x2, x2, #1          // i++
        B SE_Loop               // Keep Looping

    SE_False:
        mov x0, #0              // set x0 as #0 for false
        B SE_End                // end 

    SE_True:
        // Test if the other string also ended
        cmp x4, #0              // If str2's char is not null
        B.NE SE_False           // Jump false

        mov x0, #1              // set x0 as #1 for true

    SE_End:
    // Preverse registers by reversed order
    ldr x4, [SP], #16       // POP
    ldr x3, [SP], #16       // POP
    ldr x2, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location

    RET                     // Return

//==================================================//
// Function String_toLowerCase
// Params:
// x0 = String Address
// Returns:
// x0 = String Address
// Converts string to lower case letters
// NOTE: This converts in-place
String_toLowerCase:
    str LR, [SP, #-16]!     // Store linker
    // Preserve registers
    str x1, [SP, #-16]!     // Push
    str x2, [SP, #-16]!     // Push

    mov x1, #0              // i = 0
    TLC_loop:
        ldrb w2, [x0, x1]   // load character

        // End loop if reached null char
        cmp x2, #0          // compare to null
        B.EQ TLC_endLoop    // end loop if equals

        // If in ascii range [65, 90], add +32
        cmp x2, #65             // Test if >= 65
        B.GE TL_greater         // Branch to greater

        B TL_end                // Jump to end to keep looping

        TL_greater:
            cmp x2, #90         // Test if <= 90
            B.LT TL_change      // Branch to add 34
            B TL_end            // Goto end

        TL_change:
            add x2, x2, #32     // convert to lowercase
            strb w2, [x0, x1]   // convert byte in string

        TL_end:
            add x1, x1, #1      // i++
            B TLC_loop          // keep looping

    TLC_endLoop:
    ldr x2, [SP], #16       // POP
    ldr x1, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

 //==================================================//
// Function Substring_1
// Params:
// x0 = String Address
// x1 = String address
// Returns:
// x0 = bool (byte)
// Checks if a string is substring too= another string  
//
// Loop through the characters in string1
Substring_1:
    str LR, [SP, #-16]!     // Store linker
    // Preserve registers
    str x2, [SP, #-16]!     // Push string1
    str x3, [SP, #-16]!     // Push string2
    str x4, [SP, #-16]!     // Push
    str x5, [SP, #-16]!     // Push

  // calculate the length of the substring
ldr x0, =szS1
bl  String_length
ldr x3, =szBuffer

ldr x0, =szS2
bl  String_length
ldr x4, =szBuffer

// loop through the source string
mov x5, #0     // initialize counter for source string
loop3:
    // compare the substring with the current window in the source string
    mov x6, #0     // initialize counter for substring
    loop4:
        ldrb w3, [x0, x5]   // load a byte from the source string
        ldrb w4, [x1, x6]       // load a byte from the substring
        cmp w3, w4
        b.ne not_found          // if they don't match, move on to next window
        add x6, x6, #1          // increment counter for substring
        cbz w4, found           // check if it is null terminator (end of substring)
        b loop4                 // continue comparing bytes
        
    found:
        mov x0, #1              //set to true
        b  done

    not_found:
        // move the window one character to the right
        add x5, x5, #1      // increment counter for source string
        sub x3, x3, #1      // decrement counter for remaining characters in source string
        cmp x3, x5          // check if we have reached the end of the source string
        b.lo not_found      // if so, substring not found, exit loop
        b loop3             // continue searching for substring
    done:
       // Preverse registers by reversed order
    ldr x5, [SP], #16       // POP
    ldr x4, [SP], #16       // POP
    ldr x3, [SP], #16       // POP
    ldr x2, [SP], #16       // POP
    ldr LR, [SP], #16       // Load return location

    RET                     // Return

//==================================================//
// Function indexOf
// Params:
// x0 = String Address
// x1 = String Address to search for
// Returns:
// x0 = int
// Returns last occurrence of a string in the string. Ignores case.
indexOf:
    str LR, [SP, #-16]!     // Store linker
    str x18, [SP, #-16]!     //PUSH so can use as general purpose register
    str x19, [SP, #-16]!     //PUSH so can use as general purpose register
    str x20, [SP, #-16]!     //PUSH so can use as general purpose register
    str x21, [SP, #-16]!     //PUSH so can use as general purpose register
    str x22, [SP, #-16]!     //PUSH so can use as general purpose register
    str x23, [SP, #-16]!     //PUSH so can use as general purpose register
    str x24, [SP, #-16]!     //PUSH so can use as general purpose register
    str x25, [SP, #-16]!     //PUSH so can use as general purpose register
    str x26, [SP, #-16]!     //PUSH so can use as general purpose register
    str x27, [SP, #-16]!     //PUSH so can use as general purpose register
    str x28, [SP, #-16]!     //PUSH so can use as general purpose register
    str x29, [SP, #-16]!     //PUSH so can use as general purpose register

    mov x20, x0             // moves x0 into x20 (string to search)
    mov x21, x1             // moves x1 into x21 (string to search for)

    // Get lengths and test if should search
    bl String_length
    mov x22, x0             // moves x0 into x22 (length of string to search)
    mov x0, x21             // moves x21 into x0 (string to search for)
    bl String_length        // gets length of string to search for
    mov x23, x0             // moves x0 into x23 (length of string to search for)

    cmp x22, x23            // compares x22 and x23
    B.LT indexOfNone        // if x22 is less than x23 jump to exit

    // Convert to lowercase
    mov x0, x20             // Move address into x0
    bl String_copy          // Copy string
    bl String_toLowerCase   // Convert to lowercase
    mov x20, x0             // Copy address into x20

    mov x0, x21             // Copy into x0
    bl String_copy          // Copy string in x0
    bl String_toLowerCase
    mov x21, x0             // Copy into x23

    // Init variables
    mov x24, #0             // i = 0
    mov x25, #0             // z = 0
    mov x26, #0             // string byte
    mov x27, #0             // search byte
    // x22 = length of string
    // x23 = length of substring

    loopIndexOf1:
    sub x28, x22, x23       // length - i
    cmp x24, x28            // compares x24 and x28
    B.GT indexOfNoneWMalloc

    mov x19, #1             // match = true
    mov x25, #0             // z = 0
    loopIndexOf2:
        cmp x25, x23        // z < substr.length()
        B.GE loopIndexOf2End

        // Begin if statement
        add x18, x24, x25       // z + i
        ldrb w26, [x20, x18]    // Load byte from string
        ldrb w27, [x21, x25]    // Load byte from search string
        cmp x26, x27            // Compare bytes
        B.NE indexOfIf1         // If not equal jump to exit
        B indexOfIfS1           // Skip over

        indexOfIf1:
            mov x19, #0         // match = false
            B loopIndexOf2End   // Break out of loop
        // End if statement
        indexOfIfS1:

        add x25, x25, #1    // z++ Increment index
        B loopIndexOf2
    loopIndexOf2End:
    cmp x19, #1             // if match is successfull
    B.EQ indexOfFoundMatch  // If true, return index

    add x24, x24, #1        // Increment index
    B loopIndexOf1          // i++ keep looping

indexOfFoundMatch:
    // Free Memory
    mov x0, x20             // load string address
    bl free                 // free memory
    mov x0, x21             // load string address
    bl free                 // free memory
    mov x0, x24             // moves x24 into x0 (index)
    B indexOfExit2

indexOfNone:
    mov x0, #-1             // moves -1 into x0 (index)
    B indexOfExit2          // Exit

indexOfNoneWMalloc:
    // Free Memory
    mov x0, x20             // load string address
    bl free                 // free memory
    mov x0, x21             // load string address
    bl free                 // free memory
    mov x0, #-1             // moves -1 into x0 (index)
    B indexOfExit2          // Exit

indexOfExit2:
    ldr x29, [SP], #16      //POP so value is restored in register
    ldr x28, [SP], #16      //POP so value is restored in register
    ldr x27, [SP], #16      //POP so value is restored in register
    ldr x26, [SP], #16      //POP so value is restored in register
    ldr x25, [SP], #16      //POP so value is restored in register
    ldr x24, [SP], #16      //POP so value is restored in register
    ldr x23, [SP], #16      //POP so value is restored in register
    ldr x22, [SP], #16      //POP so value is restored in register
    ldr x21, [SP], #16      //POP so value is restored in register
    ldr x20, [SP], #16      //POP so value is restored in register
    ldr x19, [SP], #16      //POP so value is restored in register
    ldr x18, [SP], #16      //POP so value is restored in register
    ldr LR, [SP], #16       //pop back link register back into place
    RET                     //jump back to calling program location
