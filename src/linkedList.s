// Linked List Functions
// Scott M. & Jack E.
// CS3B: Rasm4
// 4.6.2023

.data
.global linkedList
.text

linkedList:
//==================================================//
// Function freeLinkedList
// Params: None
// Returns: None 
freeLinkedList:
    str LR, [SP, #-16]!     // Store linker

    ldr x20, =headPtr       // Load starting address
    ldr x20, [x20]          // Load starting node
    cmp x20, #0             // If headptr has no node
    B.EQ freeLoopEnd        // then skip doing anything

    loopFree:
        ldr x21, [x20, #8]  // x21 = next node ptr
        ldr x22, [x20]      // x22 = string ptr
        
        mov x0, x22         // Setup Param
        bl free             // Clear String Memory

        mov x0, x20         // Move pointer of node to param 0
        bl free             // Free Memory

        cmp x21, #0         // If the next node ptr is null
        B.EQ freeLoopEnd        // Jump to end

        mov x20, x21        // Move the next node ptr as current
        B loopFree         // Keep Looping

    freeLoopEnd:

    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function appendString
// Params:
// x0 = string address
// Returns:
// None
appendString:
    str LR, [SP, #-16]!     // Store linker
    str x19, [SP, #-16]!    // Preserve

    // Malloc a new string
    bl String_copy          // Copies the static string into a dynamic string (rasm3 function)

    // Load string into dynamic data
	mov x19, x0

    // Increment number of malloc'd data (16 for node, + string length + 1)
    bl strlength            // passes the malloc'd string in to get it's length
    add x1, x0, #17         // length + node size + 1 (null char)
    ldr x0, =iMemoryBytes   // Load var address
    ldr x2, [x0]            // Get value inside
    add x1, x1, x2          // Increment data from previous
    str x1, [x0]            // Store value

    ldr x0, =iNumNodes      // Load address
    ldr x1, [x0]            // Get value
    add x1, x1, #1          // Increment value by one
    str x1, [x0]            // Store new value

    // Create new linked list node
    mov x0, #16             // size of 16
    bl malloc               // Dedicate memory


    // Store new dynamic node as newNodePtr
    ldr x1, =newNodePtr     // load address
    str x0, [x1]            // put malloc memory address into pointer
    mov x2, x0

    // Place str address into the new node
    mov x0, x19
    str x0, [x2]            // put dynamic str ptr into dynamic node (first 8 bytes)

    // Store null for next address
    mov x3, #0
    str x3, [x2, #8]

    // Transverse thru linked list and add the newNodePtr to the end:
    // Loop until headPtr on the node is null
    // Tail ptr should hold the last node in the list.

    ldr x0, =headPtr        // Load address of pointer
    ldr x1, [x0]            // Get value in pointer
    cmp x1, #0
    B.EQ storeNodeHead
    
    loopFindTail:
        // x1 = current node
        // x2 = next node
        // x3 = temp new node
        // There is more than 0 nodes:
        ldr x2, [x1, #8]        // Get next ptr in node
        cmp x2, #0              // if null
        B.EQ loopStoreNode
        B loopFindNext
        
        loopStoreNode:
            // Store new pointer into last 8 bytes
            ldr x3, =newNodePtr     // Load address of new node
            ldr x3, [x3]            // Get dynamic memory of node address
            str x3, [x1, #8]        // Stores it, with offset of 8
            B appendStringEnd

        loopFindNext:
            mov x1, x2              // Move the next node's address as the current
            B loopFindTail          // Keep Looping


    storeNodeHead:
        ldr x0, =headPtr
        ldr x1, =newNodePtr     // Load address for the pointer
        ldr x1, [x1]            // Get address inside pointer
        str x1, [x0]            // Store node into the headPtr

    appendStringEnd:
        ldr x19, [SP], #16      // Preserve
        ldr LR, [SP], #16       // Load return location
        RET                     // Return

//==================================================//
// Function printLinkedList
// Params:
// x0 = headPtr
// Returns:
// None
printLinkedList:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x25, [SP, #-16]!    // Preserve

    ldr x0, =szPrintResult  // Load address of prompt
    bl putstring            // Print

    ldr x0, =headPtr        // Load address
    ldr x0, [x0]            // Load malloc address of the first node
    cmp x0, #0              // If first node is null..
    B.EQ printError         // Print an error
    mov x25, #0             // Current index = 0

    ldr x0, =headPtr        // get node address
    ldr x1, [x0]            // Load the malloc address

loopPrint:
    mov x0, x25             // Get param index
    bl printIndex           // Print index

    ldr x20, [x1, #8]       // Load last 8 bytes (node address)
    ldr x0, [x1]            // Load first 8 bytes (string address)
    bl putstring            // Print

    ldr x0, =chCr           // Load newline address
    bl putch                // Print

    cmp x20, #0             // if next pointer is null.. end loop
    B.NE printMore          // Continue Looping
    B printRet              // End Loop

printMore:
    add x25, x25, #1        // Increment count
    mov x1, x20             // Put the next node's address in for the current
    B loopPrint             // Keep Looping

printError:
    ldr x0, =strError       // Prints an error that there is no linked list
    bl putstring            // Print

printRet:
    ldr x25, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return
    
//==================================================//
// Function searchIndex
// Params:
//  x0 = index (int)
// Returns:
//  x0 = node
//  x1 = previous node
searchIndex:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x21, [SP, #-16]!    // Preserve
    str x22, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve
    str x24, [SP, #-16]!    // Preserve

    mov x22, x0             // Save look for index
    mov x23, #0             // Previous node
    mov x21, #0             // Current index = 0

    ldr x0, =headPtr        // Load address
    ldr x0, [x0]            // Load malloc address of the first node
    cmp x0, #0              // If first node is null..
    B.EQ searchNone         // Print an error

    ldr x0, =headPtr        // get node address
    ldr x1, [x0]            // Load the malloc address

loopSearch:

    // Load next node
    ldr x20, [x1, #8]       // Load last 8 bytes (node address)
    //ldr x0, [x1]            // Load first 8 bytes (string address)

    //sub x24, x21, #1        // Index - 1
    cmp x21, x22            // If current index = search'd index
    B.EQ searchFound        // Found

    cmp x20, #0             // if next pointer is null.. end loop
    B.EQ searchNone         // End Loop

    mov x23, x1             // Move current node into the previous node save
    add x21, x21, #1        // Increment count
    mov x1, x20             // Put the next node's address in for the current
    B loopSearch            // Keep Looping

// Result: Couldnt find any
searchNone:
    mov x0, #0              // Returns none since didn't find
    B searchEnd             // End

// Result: Found
searchFound:
    mov x0, x1              // Put found node in x0
    mov x1, x23             // Put previous node in x1

searchEnd:

    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return


//==================================================//
// Function deleteIndex
// Params:
//  x0 = index (int)
// Returns:
//  x0 = result
deleteIndex:
    str LR, [SP, #-16]!         // Store linker
    str x20, [SP, #-16]!        // Preserve
    str x21, [SP, #-16]!        // Preserve
    str x22, [SP, #-16]!        // Preserve
    str x23, [SP, #-16]!        // Preserve

    mov x20, x0                 // Stores a copy of the index

    // Search for node
    bl searchIndex              // Searches for the node using x0 as index. 
                                // Returns the current node in x0 and the previous in x1.
    cmp x0, #0                  // If couldn't find node..
    B.EQ deleteInvalid          // Print Invalid
    B preformDelete             // Else Preform delete

    // If node is invalid
    deleteInvalid:
        mov x0, #0              // 0 for fail
        B retDelete             // End

    preformDelete:
        // x0 has current node to delete
        // x1 has previous
        mov x21, x0             // Copy current node address
        mov x22, x1             // Copy previous node address
        ldr x23, [x0, #8]       // Load next node address
        
        // Update counters
        ldr x0, [x21]           // Load string address
        bl strlength            // Gets the string length in x0
        ldr x1, =iMemoryBytes   // Load memory counter
        ldr x2, [x1]            // Load old value
        sub x2, x2, x0          // Subtract str length
        sub x2, x2, #17         // Sub 1 for the string null + malloc
        str x2, [x1]            // Store new value

        ldr x1, =iNumNodes      // Load memory counter
        ldr x2, [x1]            // Load old value
        sub x2, x2, #1          // iNumNodes--
        str x2, [x1]            // Store new value




        // Free memory
        ldr x0, [x21]           // Load string address
        bl free                 // Free String memeory

        mov x0, x21             // Load node address into x0
        bl free                 // Free node



    
        // Return success
        mov x0, #1              // Return success

        // Free Memory
        // If delete index is 0 (the head)..
        cmp x20, #0             // If index is head
        B.EQ deleteHead         // Delete head

        cmp x23, #0             // If no child node..
        B.EQ deleteEnd          // Delete End

        // Delete middle here
        str x23, [x22, #8]      // Loads the next node address into the previous
        B retDelete             // End
    deleteHead:
        // Make index 1 the head
        ldr x2, =headPtr        // Load head ptr

        cmp x23, #0             // If next is invalid..
        B.EQ deleteHeadInvalid  // Set head as invalid

        str x23, [x2]           // Set the new headptr as the next node
        B retDelete             // End

        deleteHeadInvalid:
            mov x1, #0          // Load temp value 0
            str x1, [x2]        // Store null into headptr
            B retDelete         // End

    deleteEnd:
        // Remove current index and update previous
        mov x1, #0              // Get temp value 0
        str x1, [x22, #8]       // Set next node ref to 0

    retDelete:
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function: searchString
// Param:
//  x0 = String to search
//  x1 = Print?
// Returns:
//  x0 = Number of hits
//  x1 = Number total transversed
searchString:
    str LR, [SP, #-16]!     // Store linker
    str x20, [SP, #-16]!    // Preserve
    str x21, [SP, #-16]!    // Preserve
    str x22, [SP, #-16]!    // Preserve
    str x23, [SP, #-16]!    // Preserve
    str x24, [SP, #-16]!    // Preserve
    str x25, [SP, #-16]!    // Preserve
    str x27, [SP, #-16]!    // Preserve

    mov x22, x0             // Save look for string
    mov x23, #0             // Previous node
    mov x21, #0             // Current index = 0
    mov x27, #0             // hit counter = 0
    mov x25, x1

    ldr x0, =headPtr        // Load address
    ldr x0, [x0]            // Load malloc address of the first node
    cmp x0, #0              // If first node is null..
    B.EQ stringNone         // Print an error

    ldr x0, =headPtr        // get node address
    ldr x24, [x0]           // Load the malloc address

loopString:

    // Load next node
    ldr x20, [x24, #8]      // Load last 8 bytes (node address)
    add x21, x21, #1        // Increment count
    ldr x0, [x24]           // Param: The string to search (first 8 bytes)
    mov x1, x22             // Param: The string to find
    bl  indexOf             // find substring
    cmp x0, #-1
    B.NE stringFound        // Found
stringContinue:

    cmp x20, #0             // if next pointer is null.. end loop
    B.EQ stringNone         // End Loop

    mov x24, x20            // Put the next node's address in for the current
    B loopString            // Keep Looping

// Result: Couldnt find any
stringNone:
    mov x0, #0              // Returns none since didn't find any
    B searchStringEnd       // End

// Result: Found
stringFound:
    cmp x25, #0             // Should Print?
    B.EQ skipSearchPrint    // False = Skip

    ldr x0, =szLine         // line formatting
    bl putstring            // print to terminal
    mov x0, x21             // Get param index
    bl printIndex           // Print index
    ldr x0, [x24]           // Get string address in node
    bl putstring            // Print String
    ldr x0, =chCr           // Get address
    bl putch                // Print newline
    
skipSearchPrint:
    add x27, x27, #1        // increment hit counter
    B stringContinue        // Keep looping

searchStringEnd:
    mov x0, x27             // Return number of hits
    mov x1, x21             // Return total transversed
    ldr x27, [SP], #16      // Preserve
    ldr x25, [SP], #16      // Preserve
    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return

//==================================================//
// Function editString
// Params:
//  x0 = index (int)
// Returns:
//  x0 = result
editString:
    str LR, [SP, #-16]!         // Store linker
    str x20, [SP, #-16]!        // Preserve
    str x21, [SP, #-16]!        // Preserve
    str x22, [SP, #-16]!        // Preserve
    str x23, [SP, #-16]!        // Preserve
    str x24, [SP, #-16]!        // Preserve


    mov x20, x0                 // Stores a copy of the index

    // Search for node
    bl searchIndex              // Searches for the node using x0 as index. 
                                // Returns the current node in x0 and the previous in x1.
    cmp x0, #0                  // If couldn't find node..
    B.EQ editInvalid            // Print Invalid
    B preformEdit               // Else Preform dedit

    // If node is invalid
    editInvalid:
        ldr x0, =szInvalidIndex
        bl  putstring
        mov x0, #0              // 0 for fail
        B retEdit               // End

    preformEdit:
        // x0 has current node to edit
        mov x21, x0             // Copy current node address
        ldr x0, [x21]           // Load old string
        bl  String_length       // Get length
        mov x23, x0             // hold onto old length

        // Prompt user for new string
        ldr x0, =szInputString  // Load prompt address
        bl putstring            // Print string
        bl clearBuffer          // Clear buffer
        ldr x0, =kbBuf          // Allocate an output for the string
        mov x1, MAXBYTES        // Associate storage size for getstring
        bl getstring            // Get user input
       
        // Clear previous string
        ldr x0, [x21]           // Load old string address
        bl  free

        // Print index
        mov x0, x20             // Get param index
        bl printIndex           // Print index

        // Malloc new string
        ldr x0, =kbBuf          // Load string data
        bl String_copy          // Copy (malloc)
        mov x24, x0             // copy address output from String_copy
        str x0, [x21]           // Put into first 8 bytes of node

        // Print Line
        bl putstring

        //get length of new string
        mov x0, x24
        bl String_length        // Gets the string length in x0

        ldr x1, =iMemoryBytes   // Load memory counter
        ldr x3, [x1]            // Load old value
        add x3, x3, x0          // Add New Str Length
        sub x3, x3, x23         // Sub Old Str Length
        str x3, [x1]            // Store new value

        //new line
        ldr x0, =chCr           // Get address
        bl putch                // Print newline
    

    retEdit:
    ldr x24, [SP], #16      // Preserve
    ldr x23, [SP], #16      // Preserve
    ldr x22, [SP], #16      // Preserve
    ldr x21, [SP], #16      // Preserve
    ldr x20, [SP], #16      // Preserve
    ldr LR, [SP], #16       // Load return location
    RET                     // Return


    