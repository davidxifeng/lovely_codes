//Created:  02/29/2012 09:32:41
//davidxifeng@gmail.com
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned int uint;

enum bool
{
    false = 0,
    true
};

typedef enum bool bool;

struct PosType
{
    int x;
    int y;
};
typedef struct PosType PosType;

struct MazeInfo
{
    int ord;
    PosType seat;
    int dir;
};
typedef struct MazeInfo MazeInfo;

struct Stack
{
    uint stack_capacity;
    uint increase_size;
    void * base;
    void * top;
    uint elem_size;
    uint stack_size;
};

typedef struct Stack Stack;

void stack_init(Stack * s, uint a, uint b, uint elem_size)
{
    s->stack_capacity = a;
    s->increase_size = b;
    s->elem_size = elem_size;

    s->base = malloc(s->stack_capacity * elem_size);
    s->top = s->base;
    s->stack_size = 0;
}

void stack_push(Stack * s, const void * elem)
{
    if( s->stack_size + 1 > s->stack_capacity)
    {
        s->base = realloc(s->base,
            (s->stack_capacity+s->increase_size) * s->elem_size);
        s->stack_capacity += s->increase_size;
    }
    ++ s->stack_size;
    memcpy(s->top, elem, s->elem_size);
    s->top += s->elem_size;
}

bool stack_pop(Stack * s, void * elem)
{
    if( s->stack_size > 0)
    {
        -- s->stack_size;
        s->top -= s->elem_size;
        memcpy(elem, s->top, s->elem_size);
        return true;
    }
    return false;
}

//should use a print func argument
void stack_print(Stack * s)
{
    if( s->stack_size == 0)
    {
        printf("stack %x is empty.\n", s->base);
    }
    else
    {
        for(int i = 0; i< s->stack_size; ++i)
        {
            printf("%d ",
                * (int *)(s->base + i * s->elem_size));
        }
        printf("\n");
    }
}

void stack_destroy(Stack * s)
{
    free(s->base);
    s->base = NULL;
    s->top = NULL;
    s->stack_capacity = 0;
    s->stack_size = 0;
}

int main(void)
{
    Stack s;
    stack_init(&s, 20, 5, sizeof(int));
    int a[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    int b[10] ;
    stack_print(&s);
    stack_push(&s, &a[4]);
    stack_push(&s, &a[0]);
    stack_push(&s, &a[8]);
    stack_push(&s, &a[3]);
    stack_push(&s, &a[6]);
    stack_print(&s);
    stack_pop(&s,&b[0]);
    stack_print(&s);

    stack_pop(&s,&b[0]);
    stack_pop(&s,&b[0]);
    stack_pop(&s,&b[0]);
    stack_print(&s);
    stack_pop(&s,&b[0]);
    stack_print(&s);

    stack_destroy(&s);
    stack_print(&s);
    return 0;
}


