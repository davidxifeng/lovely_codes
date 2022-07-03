#include <stdio.h>
#include <stdlib.h>

// 2014-11-24

static int malloc_count = 0;

void * my_malloc(size_t size) {
    void * p = malloc(size);
    //printf("malloc %p\n", p);
    malloc_count++;
    return p;
}

void my_free(void * ptr) {
    //printf("free %p\n", ptr);
    free(ptr);
    malloc_count--;
}

void check_malloc_count() {
    if (malloc_count != 0) {
        printf("ERROR: malloc %d\n", malloc_count);
    }
}

#define malloc my_malloc
#define free my_free
#define bool int
#define true 1
#define false 0

struct ListNode {
    struct ListNode *next;
    int val;
};

void create_list(int a[], int c, struct ListNode ** list);
void free_list(struct ListNode ** list);
void print_list(struct ListNode * list);

// 1 2 3 4 => 2 1 4 3
struct ListNode *swapPairs(struct ListNode *head) {
    if (head && head->next) {
        struct ListNode *r, *bh;

        // save head
        r          = head->next;

        head->next = r->next;
        r->next    = head;
        bh         = head;
        head       = head->next;

        while (head && head->next) {
            bh->next       = head->next;

            head->next     = bh->next->next;
            bh->next->next = head;
            bh             = head;
            head           = head->next;
        }
        return r;
    } else {
        return head;
    }
}

struct ListNode * swapPairs_by_ulyx(struct ListNode * head);

void test(int test[], int n) {
    struct ListNode *list;
    create_list(test, n, &list);
    print_list(list);
    list = swapPairs(list);
    //list = swapPairs_by_ulyx(list);
    print_list(list);
    free_list(&list);
    printf("\n");
}

int main(int argc, char const* argv[]) {
    int t1[] = {1,2,3,4};
    test(t1, 4);
    int t2[] = {1,2,3,4,5};
    test(t2, 5);
    int t3[] = {1,2,3,4,5,6};
    test(t3, 6);
    int t4[] = {1,2};
    test(t4, 2);
    int t5[] = {};
    test(t5, 0);

    check_malloc_count();
    return 0;
}

void create_list(int a[], int c, struct ListNode ** list) {
    if (c >= 1) {
        struct ListNode * node = malloc(sizeof(*node));

        *list = node;

        node->val = a[0];
        node->next = NULL;

        for (int i = 1; i < c; ++i) {
            struct ListNode * new_node = malloc(sizeof(*new_node));
            new_node->val = a[i];
            new_node->next = NULL;

            node->next = new_node;
            node = new_node;
        }
    } else {
        *list = NULL;
    }
}

void free_list(struct ListNode ** list) {
    struct ListNode * node = *list;
    while(node) {
        struct ListNode * next = node->next;
        free(node);
        node = next;
    }
    *list = NULL;
}

void print_list(struct ListNode * list) {
    int c = 0;
    while (list) {
        printf("{%d: [%d]} -> ", c++, list->val);
        list = list->next;
    }
    printf("\n");
}

struct ListNode * swapPairs_by_ulyx(struct ListNode * head) {
    if (head && head->next) {
        struct ListNode * newhd = head->next;
        head->next = swapPairs(newhd->next);
        newhd->next = head;
        return newhd;
    } else {
        return head;
    }
}
