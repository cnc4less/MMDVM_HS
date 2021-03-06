/*
 *   Copyright (C) 2016 by Andy Uribe CA6JAU
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* Required amount of heap and stack */
_min_heap_size = 0x1000;
_min_stack_size = 0x0800;

/* The entry point in the interrupt vector table */
ENTRY(Reset_Handler)

/* Memory areas */
MEMORY
{
	ROM (rx)      : ORIGIN = 0x08000000, LENGTH = 64K    /* FLASH */
	RAM (xrw)     : ORIGIN = 0x20000000, LENGTH = 20K    /* Main RAM */
}

/* Stack start address (end of 20K RAM) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
	.text : 
	{ 
		/* The interrupt vector table */
		. = ALIGN(4);
		KEEP(*(.isr_vector .isr_vector.*))
		
		/* The program code */
		. = ALIGN(4);
		*(.text .text*)
		*(.rodata .rodata*)
		
		/* ARM-Thumb code */
		*(.glue_7) *(.glue_7t)              
		
		. = ALIGN(4);
		KEEP(*(.init))
		KEEP(*(.fini))
		
		/* EABI C++ global constructors support */
		. = ALIGN(4);
		__preinit_array_start = .;
		KEEP (*(.preinit_array))		
		__preinit_array_end = .;
		
		/* EABI C++ global constructors support */
		. = ALIGN(4);
		__init_array_start = .;
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array))
		__init_array_end = .;
		
		/* EABI C++ global constructors support */
		. = ALIGN(4);
		__fini_array_start = .;
		KEEP (*(.fini_array))
		KEEP (*(SORT(.fini_array.*)))
		__fini_array_end = .;

	} > ROM
 
 	/* ARM sections containing exception unwinding information */
	.ARM.extab : {
		__extab_start = .;
		*(.ARM.extab* .gnu.linkonce.armextab.*) 
		__extab_end = .;
	} > ROM
	
	/* ARM index entries for section unwinding */
	.ARM.exidx : {
		__exidx_start = .;
		*(.ARM.exidx*)
		__exidx_end = .;
	} > ROM
    
    /* Start address for the initialization values of the .data section */
	_sidata = .;

	/* The .data section (initialized data) */
	.data : AT ( _sidata )
	{
		. = ALIGN(4);
		_sdata = . ;       /* Start address for the .data section */
		*(.data .data*)
		
		. = ALIGN(4);
		_edata = . ;       /* End address for the .data section */
	} > RAM

	/* The .bss section (uninitialized data) */
	.bss :
	{
		. = ALIGN(4);
		_sbss = .;         /* Start address for the .bss section */
		__bss_start__ = _sbss;
		*(.bss)
		*(.bss*)
		*(COMMON)
		
		. = ALIGN(4);
		_ebss = . ;        /* End address for the .bss section */
    	__bss_end__ = _ebss;
	} > RAM

	/* Space for heap and stack */
	.heap_stack :
	{
		end = . ;		  		 /* 'end' symbol defines heap location */
		_end = end ;
		. = . + _min_heap_size;  /* Additional space for heap and stack */
		. = . + _min_stack_size;
	} > RAM

	/* Remove information from the standard libraries */
	/DISCARD/ :
	{
		libc.a ( * )
		libm.a ( * )
		libgcc.a ( * )
	}
}
