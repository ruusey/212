/*
 *  Copyright 2018
 *
 *  Created on: Apr 24, 2018
 *  Author: Robert Usey
 *  CSCE212 Homework 5
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "../include/alist.h"

alist_t* alalloc(void) {
	//ALLOCATE MEMORY FOR NEW LIST THAT IS THE SIZE OF ALIST STRUCT
	alist_t *newList = malloc(sizeof(alist_t));
	//SIZE STARTS AT 0
	newList->size = 0;
	//DEFAULT LENGTH = 10
	newList->len = DEFAULT_LEN;
	//ALLOCATE MEMORY FOR EACH POINTER IN ARRAY OF DATA (10 * sizeof void ptr)
	newList->arr = malloc(sizeof(void *) * DEFAULT_LEN);
	//RETURN POINTER TO MEMORY ALLOCATED FOR THE NEW LIST
	return newList;
}
void push(alist_t *lst, void* item) {
	//LIST NEW SIZE AFTER ADDING ANOTHER ITEM
	unsigned int size = lst->size + 1;
	//IF THIS WILL PUT US OVER OUR LENGTH
	if (size > lst->len) {
		//NEW CAPACITY = SIZE+1 * 2
		unsigned int new_length = size;
		new_length *= 2;
		//REALOCATE THE MEMORY FOR ARR
		lst->arr = realloc(lst->arr, sizeof(void*) * new_length);
		//SET THE NEW LENGTH AND ASSIGN ITEM TO SIZE INDEX THEN INCREMENT THE LISTS SIZE
		lst->len = new_length;
		lst->arr[lst->size++] = item;
	} else {
		lst->arr[lst->size++] = item;
	}

}
void* pop(alist_t *lst) {
	//SIZE > 0
	assert(lst->size > 0);
	unsigned int size = lst->size - 1;
	//WE NEED TO RESIZE THE LIST
	if (size <= lst->len / 4) {
		//NEW CAPACITY = length / 2
		unsigned int new_capacity = lst->len / 2;
		//REALOCATE THE MEMORY FOR ARR
		lst->arr = realloc(lst->arr, sizeof(void*) * new_capacity);
		//SET NEW LENGTH AND RETURN --SIZE INDEX ELEMENT(last)
		lst->len = new_capacity;
		return lst->arr[--lst->size];
	} else {
		return lst->arr[--lst->size];
	}

}
void* find(alist_t *lst, bool (*sel)(void*)) {
	//FOR ALL ELEMENTS IN LIST
	for (unsigned int i = 0; i < lst->size; i++) {
		void* val = lst->arr[i];
		//IF CALLING SEL ON THIS VALUE RETURNS TRUE, RETURN THE VALUE
		if ((*sel)(val)) {
			return val;
		}

	}
	//OTHERIWSE RETURN NULL
	return NULL;

}
void map(alist_t *lst, void* (*func)(void*)) {
	for (unsigned int i = 0; i < lst->size; i++) {
		void* val = lst->arr[i];
		//APPLY FUN TO THIS VALUE AND REASIGN ITS INDEX TO HOLD THE NEW MAPPED VALUE (mutate original)
		val = (*func)(val);
		lst->arr[i] = val;

	}
}

