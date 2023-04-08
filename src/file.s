// File Functions
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023

.data
    // FILE MODES
    .equ R, 00              // read only
    .equ W, 01              // write only
    .equ RW, 02             // read write 
    .equ T_RW, 01002        // truncate read write
    .equ C_W, 0101          // create file if does not exist
    // FILE PERMISSIONS 
    .equ RW______, 0600     // 
    .equ CURRNDIR, -100     // Means that the file is in the local directory

    szReadContents:     .skip 32768    // Buffer of file contents. 1 extra byte to hold a null character.
.global file
.text

file:
//==================================================//
// Function appendFileContents
// Params: x0 = fileLocation (address)
// Returns: x0 = fileContents (address)
appendFileContents:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve
    str x24, [SP, #-16]!    // Preserve

    mov x1, x0              // moves x0 param into x1
    
    // Open/Create Write File
    mov x0, #CURRNDIR       // special current directory number
    mov x2, #R              // FLAGS
    mov x3, #RW______       // MODE

    mov x8, #56             // open (found in arm64.asyscall.sh)
    svc 0                   // returns file descriptor in x0

    mov x20, x0             // Copies the file to x22
    mov x0, x20             // Setup file param
    bl readFileChunk

loopRead:
    ldr x0, =szReadContents // Pass contents as param
    bl getReadLine          // Read Line
    bl appendString         // Appends string to linked list

    ldr x0, =szReadContents // Get contents
    ldrb w23, [x0, x24]     // Get next byte
    cmp w23, #0             // If null byte
    B.EQ endReadFile        // Reached end of file if null
    B loopRead

endReadFile:
    mov x0, x20             // Get file from temp register
    mov x8, #57             // close file
    svc 0

    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//========================================//
// Get Line
// Parems: 
//      x0 = address of contents
//      x1 = offset
// Returns: x0 = buffer of a complete string
getReadLine:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x21, [SP, #-16]!    // Preserve
    str x22, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve

    mov x20, x0             // Stores contents param in x20
    mov x23, #0             // Init buffer counter to 0
    bl clearBuffer          // Clears buffer. Important to make all values 0 again

    ldr x22, =kbBuf         // Get contents buffer

    loopReadLine:

        ldrb w21, [x20, x24]        // Get byte and increment index
        add x24, x24, #1            // Increment global counter for contents

        cmp w21, #0                 // If reached end of line
        B.EQ endReadLine            // End loop

        cmp w21, '\n'               // If reached new line
        B.EQ endReadLine            // End loop

        strb w21, [x22, x23]        // Store byte into kbBuf
        add x23, x23, #1            // Increment counter for buffer offset

        B loopReadLine              // Keep looping

    endReadLine:
    ldr x0, =kbBuf
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==========================================//
// Reads a chunk of the file
// Params: 
//      x25 = offset
//      x0 = file
// Returns:
//      x0 = file. Will be 0 if end of file.
readFileChunk:
    str LR, [SP, #-16]!     // Store linker

    // Read File
    ldr x1, =szReadContents // Contents address
    mov x2, #32768          // Amount of bytes to read
    mov x8, #63             // read 
    svc 0

    mov x24, #0             // Reset contents counter

    ldr LR, [SP], #16       // Load return location
    RET                     // Return
