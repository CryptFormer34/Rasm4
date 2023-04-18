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
// Returns last occurrence of a string in the string
indexOf:
    //preserve registers
    str LR, [SP, #-16]!

    str x1, [SP, #-16]!     //PUSH so can use as general purpose register
    str x2, [SP, #-16]!     //PUSH so can use as general purpose register
    str x3, [SP, #-16]!     //PUSH so can use as general purpose register
    str x4, [SP, #-16]!     //PUSH so can use as general purpose register
    str x5, [SP, #-16]!     //PUSH so can use as general purpose register
    str x6, [SP, #-16]!     //PUSH so can use as general purpose register
    str x7, [SP, #-16]!     //PUSH so can use as general purpose register
    str x8, [SP, #-16]!     //PUSH so can use as general purpose register
    str x9, [SP, #-16]!     //PUSH so can use as general purpose register
    str x10, [SP, #-16]!     //PUSH so can use as general purpose register
    str x11, [SP, #-16]!     //PUSH so can use as general purpose register
    str x12, [SP, #-16]!     //PUSH so can use as general purpose register
    str x13, [SP, #-16]!     //PUSH so can use as general purpose register
    str x14, [SP, #-16]!     //PUSH so can use as general purpose register
    str x15, [SP, #-16]!     //PUSH so can use as general purpose register
    str x16, [SP, #-16]!     //PUSH so can use as general purpose register
    str x17, [SP, #-16]!     //PUSH so can use as general purpose register
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

    //x0 = s1 length (index)
    //x1 = s2
    //x2 = temp index for loop
    //x3 = cuurent character of s1
    //x4 = s1
    //x5 = s2 index (final)
    //x6 = s2 index (in loop)
    //x7 = first character of s2

    // Convert to lowercase
    mov x23, x1             // Copy address
    bl String_copy          // Copy string in x0
    bl String_toLowerCase
    mov x24, x0             // Copy address into x24

    mov x0, x23             // Copy into x0
    bl String_copy          // Copy string in x0
    bl String_toLowerCase
    mov x23, x0             // Copy into x23
    mov x0, x24             // Move into x0 (String Address)

    // Compare the two strings
    bl String_length        // Calls function
    mov x1, x23             // Setups x1 to have length of string 0

    mov x22, #0             // Init counter = 0
    ldrb w7, [x1, #0]    //loads first s2 character value into w7
    
SLIO3_loopreturn:
    mov x6, #0           //moves 0 into x6
    mov x25, #-1          //moves -1 into x5
    ldrb w7, [x1, #0]    //loads first s2 character value into w7
SLIO3_loop:
    ldrb w3, [x24, x0]    //loads current index value into w3
    cmp w3, w7           //compares w3 and character in w1
    B.EQ SLIO3_match            //if equal jump to exit
    sub x0, x0, #1       //x0 = x0 - 1
    cmp x0, #0           //compares x2 and x0
    B.LT SLIO3_exit            //if greater than jump to exit
    b SLIO3_loop               //unconditional jump to top of loop

    //while (byte != x1 character or index <= string_length)
SLIO3_match:
    mov x25, x0      //moves x0 into x5
    mov x22, x0      //moves x0 into x4
    sub x0, x0, #1  //x0 = x0 - 1
SLIO3_loop2:
    add x6, x6, #1       //x6 = x6 + 1
    add x22, x22, #1       //x2 = x2 + 1
    ldrb w3, [x24, x22]    //loads current index value into w3
    ldrb w7, [x1, x6]    //loads s2 character value into w7

    cmp w7, #0           //compare w7 to null
    B.EQ SLIO3_exit            //if equal jump to exit
    cmp w3, w7           //compares w3 and w7
    B.NE SLIO3_loopreturn      //if not equal jump to loopreturn

    b SLIO3_loop2              //unconditional jumpt to loop2

SLIO3_exit:
    // Free Memory
    mov x0, x23
    bl free
    mov x0, x24
    bl free

    mov x0, x25           //moves x5 (index) into x0

    //load values back into registers in reverse order
    ldr x29, [SP], #16   //POP so value is restored in register
    ldr x28, [SP], #16   //POP so value is restored in register
    ldr x27, [SP], #16   //POP so value is restored in register
    ldr x26, [SP], #16   //POP so value is restored in register
    ldr x25, [SP], #16   //POP so value is restored in register
    ldr x24, [SP], #16   //POP so value is restored in register
    ldr x23, [SP], #16   //POP so value is restored in register
    ldr x22, [SP], #16   //POP so value is restored in register
    ldr x21, [SP], #16   //POP so value is restored in register
    ldr x20, [SP], #16   //POP so value is restored in register
    ldr x19, [SP], #16   //POP so value is restored in register
    ldr x18, [SP], #16   //POP so value is restored in register
    ldr x17, [SP], #16   //POP so value is restored in register
    ldr x16, [SP], #16   //POP so value is restored in register
    ldr x15, [SP], #16   //POP so value is restored in register
    ldr x14, [SP], #16   //POP so value is restored in register
    ldr x13, [SP], #16   //POP so value is restored in register
    ldr x12, [SP], #16   //POP so value is restored in register
    ldr x11, [SP], #16   //POP so value is restored in register
    ldr x10, [SP], #16   //POP so value is restored in register
    ldr x9, [SP], #16    //POP so value is restored in register
    ldr x8, [SP], #16    //POP so value is restored in register
    ldr x7, [SP], #16    //POP so value is restored in register
    ldr x6, [SP], #16    //POP so value is restored in register
    ldr x5, [SP], #16    //POP so value is restored in register
    ldr x4, [SP], #16    //POP so value is restored in register
    ldr x3, [SP], #16    //POP so value is restored in register
    ldr x2, [SP], #16    //POP so value is restored in register
    ldr x1, [SP], #16    //POP so value is restored in register

    ldr LR, [SP], #16   //pop back link register back into place
    RET                 //jump back to calling program location

//==================================================//
