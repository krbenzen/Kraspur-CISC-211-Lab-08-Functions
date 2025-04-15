/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Benzen Raspur"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/

    push {lr}
    /*Top 16 bit to A */
    /*Shift right by 16*/
    mov     r3, r0, asr #16
    str     r3, [r1]
    /*Bottom 16 bit to B*/
    /*Shift left then arithmetic shift*/
    mov     r3, r0, lsl #16
    mov     r3, r3, asr #16
    str     r3, [r2]
    pop     {pc}
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push    {lr}
    cmp     r0, #0
    bge     positive
    /*If negative, flip*/
    rsb     r0, r0, #0    /* r0 = -r0 */
    mov     r3, #1
    str     r3, [r2]
    b       done
    positive:
    /*If 
     it = 0, sign bit = 0*/
    mov     r3, #0
    str     r3, [r2]
done:
    /*Store the value to memory*/
    str     r0, [r1]
    pop     {pc}
    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push    {r4, lr}
    mov     r2, #0      /*Goes in r2 */
loop_start:
    cmp     r1, #0
    beq     done_mult

   /*Check if LSB of r1 is 1*/
    tst     r1, #1
    beq     skip_add
    adds    r2, r2, r0
skip_add:
    /*Shift r0 by 1, r1 by 1*/
    lsls    r0, r0, #1
    lsrs    r1, r1, #1
    b       loop_start

done_mult:
    mov     r0, r2    
    pop     {r4, pc}

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push    {lr}
    eors    r3, r1, r2
    cmp     r3, #0
    beq     fix_done
    /*If r3 = 0, flip sign of r0*/
    rsb     r0, r0, #0
fix_done:
    pop     {pc}
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
     */
    ldr     r1, =a_Multiplicand
    ldr     r2, =b_Multiplier
    bl      asmUnpack

     /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
      */
    ldr     r0, =a_Multiplicand
    ldr     r0, [r0]             /* r0 <- A */
    ldr     r1, =a_Abs
    ldr     r2, =a_Sign
    bl      asmAbs


     /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
      */
    ldr     r0, =b_Multiplier
    ldr     r0, [r0]             /* r0 <- B */
    ldr     r1, =b_Abs
    ldr     r2, =b_Sign
    bl      asmAbs


    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
     */
    ldr     r0, =a_Abs
    ldr     r0, [r0]
    ldr     r1, =b_Abs
    ldr     r1, [r1]
    bl      asmMult
    ldr     r1, =init_Product
    str     r0, [r1]

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
     */
    ldr     r1, =a_Sign
    ldr     r1, [r1]
    ldr     r2, =b_Sign
    ldr     r2, [r2]
    bl      asmFixSign
    ldr     r1, =final_Product
    str     r0, [r1]

     /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
      */
    pop     {r4, r5, r6, pc}

    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
