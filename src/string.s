// Program: String1.s
// Scott McCloskey
// CS3B: Rasm3
// 3.4.2023
// Contains the first 10 string functions for Rasm3

.data
.global string1
.text

string1:
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
    bl String_length        // Gets the length, stores in x0

    // Dedicate Memory
    add x0, x0, #1          // Add one for the null character
    str x1, [SP, #-16]!     // Preserve
    str x2, [SP, #-16]!     // Preserve
	bl malloc               // Dedicate memory
    ldr x2, [SP], #16       // Pop
    ldr x1, [SP], #16       // Pop

    mov x3, #0              // x3: i = 0
    SC_Loop:
        ldrb w2, [x1, x3]   // Load character
        cmp x2, #0          // If current char is null
        B.EQ SC_End         // End

        strb w2, [x0, x3]   // Store character into allocated string

        add x3, x3, #1      // i++
        B SC_Loop           // Keep looping

    SC_End:
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
    