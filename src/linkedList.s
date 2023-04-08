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
        B freeLoopEnd          // Keep Looping

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
// Recursive
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
    