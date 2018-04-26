/*
 * llist.c
 *
 *  Created on: Apr 25, 2018
 *      Author: ruusey
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "../include/llist.h"

llist_t *create_node(int val, llist_t *parent);
int index_of(llist_t *lst, llist_t *node);
llist_t *llalloc(int val) {
	llist_t *new_list = malloc(sizeof(llist_t));
	//SET VALUE OF NEWLIST
	new_list->val = val;
	//NEXT=null
	new_list->next = NULL;
	//RETURN POINTER TO MEMORY ALLOCATED FOR THE NEW LIST
	return new_list;
}

llist_t *copy(llist_t *lst) {
	//ALLOCATE MEMORY FOR THE COPY OF OUR LIST
	 // source pointer, top points to first entry in the list
	llist_t *str = lst;
	llist_t *dPtr = llalloc(str->val);
	llist_t *start = dPtr;
	str=str->next;
	for (; str->next != NULL; str = str->next) {
		if(value_at(dPtr,str->val)>-1)break;
		llist_t *nde = llalloc(str->val);
		dPtr->next=nde;
		dPtr=dPtr->next;
	}


	return start;
}
llist_t *convert(unsigned int *arr, unsigned int size) {
	llist_t *first = NULL, *cur = NULL;
	for (int i = 0; i < size; i++) {
		cur = create_node(arr[i], cur);
		if (first == NULL)
			first = cur;
	}
	cur = first;
	return cur;
}
proof_t *tort_hare(llist_t *lst) {
	proof_t *ret = malloc(sizeof(proof_t));
	//ret->proof= malloc(sizeof(int*));
	llist_t *slow = lst, *fast = lst;

	while (slow != NULL && fast != NULL && fast->next != NULL) {

		slow = slow->next;               //Slow moves by 1 step
		fast = fast->next->next;        //Fast moves by two steps

		//If they meet then there is a loop
		if (slow == fast) {
			//To find the starting element where the loop starts
			//fast = fast;
			slow = lst;
			while (slow != fast) {
				//Both move by 1 step
				slow = slow->next;
				fast = fast->next;
			}
			ret->return_val = slow->val;
			int index = index_of(lst, slow);
			ret->proof = &index;
			return ret;

		}

	}

	return ret; //No loop
}
void test(llist_t *lst) {

}
proof_t *rev_cycle(llist_t *lst, int num) {

	llist_t *tmp = copy(lst);
	llist_t *prev = NULL;
	llist_t *cur = tmp;

	proof_t *ret = malloc(sizeof(proof_t));
	int *arr = malloc(sizeof(arr) * num);

	int count = 0;
	while (cur != NULL) {
		if (count < num) {
			arr[count] = cur->val;
			count++;
		}
		llist_t *next = cur->next;

		cur->next = prev;
		prev = cur;
		cur = next;
	}

	if (prev == tmp && tmp != NULL && tmp->next != NULL) {
		int index = (value_at(lst, prev->val));
		printf(index);
		ret->return_val = (value_at(lst, prev->val));

		ret->proof = arr;
	} else {
		ret->return_val = -1;
		ret->proof = -1;
	}

	return ret;
}

llist_t *create_node(int val, llist_t *parent) {
	llist_t *ptr = (llist_t*) malloc(sizeof(llist_t));
	if (ptr == NULL) {
		fprintf(stderr, "Memory allocation error.\n");
		exit(1);
	}
	if (parent != NULL)
		parent->next = ptr;
	ptr->val = val;
	ptr->next = NULL;
	return ptr;
}
int index_of(llist_t *lst, llist_t *node) {
	if (lst == NULL || node == NULL)
		return -1;
	int count = 0;
	for (; lst->next != NULL; lst = lst->next) {

		if (lst == node) {
			return count;
		}
		count++;
	}

	return -1;

}
int value_at(llist_t *lst, int find) {
	if (lst == NULL)
		return -1;
	int count = 0;
	for (; lst->next != NULL; lst = lst->next) {

		if (lst->val == find) {
			return count;
		}
		count++;
	}

	return -1;

}

