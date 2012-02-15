#include <iostream>
#include <string>
#include <cctype>
#include <cstdlib>

using namespace std;

struct TStackNode
{
    string data;
    TStackNode * pPrior;
    TStackNode * pNext;
};

class MyStack
{
public:
    TStackNode * pTop;
    TStackNode * pFirst;

    MyStack();
    bool get_top(string & elem);
    void push(const string & elem);
    bool pop(string & elem);
    bool is_empty();

    void print_stack();
private:
    int length;
};

void MyStack::print_stack()
{
    if(!this->length)
    {
        cout<<"stack is null"<<endl;
        return ;
    }
    TStackNode * p = this->pFirst;
    for(int i=0;i<this->length;i++)
    {
        cout<<i+1<<" th is "<<p->data<<endl;
        p = p->pNext;
    }
}

bool MyStack::is_empty()
{
    return length == 0;
}

bool MyStack::pop(string & elem)
{
    if(length > 1)
    {
        elem = this->pTop->data;
        this->pTop = this->pTop->pPrior;
        delete this->pTop->pNext;
        this->pTop->pNext = NULL;
    }
    else if(length == 1)
    {
        elem = this->pTop->data;
        delete this->pTop;
        this->pFirst = NULL;
        this->pTop = NULL;
    }
    else
    {
        return false;
    }
    this->length --;
    return true;
}
MyStack::MyStack()
{
    this->length = 0;
    this->pTop = NULL;
    this->pFirst = NULL;
}

bool MyStack::get_top(string & elem)
{
    if (this->length > 0)
    {
        elem = this->pTop->data;
        return true;
    }
    else
    {
        return false;
    }
}

void MyStack::push(const string & elem)
{
    TStackNode * node = new TStackNode;
    node->data = elem;
    node->pNext = NULL;
    node->pPrior = this->pTop;
    if(this->length == 0)
    {
        this->length ++;
        this->pFirst = node;
        this->pTop = node;
    }
    else
    {
        this->length ++;
        this->pTop->pNext = node;
        this->pTop = node;
    }
}

bool is_operator(string s)
{
    string optrs = "+-*/^()";
    return optrs.find(s) != string::npos;
}

bool is_digital(string s)
{
    string digitals = "0123456789";//add 0.5 support later
    return digitals.find(s) != string::npos;
}

bool is_space(string s)
{
    string spaces = " \t";
    return spaces.find(s) != string::npos;
}

int get_priority(const string & optr)
{
    //use dictionary here return priority[optr]
    int result;
    if(optr == "+" || optr == "-")
    {
        result = 1;
    }
    else if(optr == "*" || optr == "/")
    {
        result = 2;
    }
    else if(optr == "^")
    {
        result = 3;
    }
    else if(optr == "(" || optr == ")")
    {
        result = 9;
    }
    return result;
}

//Feb 15
//Limitation: can't calc
//              negative value;
//              float value;
//              only +-*/^;
//              ...
string translate_expression(const string & exp)
{
    string dest = "";
    string word;
    MyStack opstk;
    string stktop;
    string cur;
    int len = exp.length();
    for(int i=0; i< len; )
    {
        cur = exp.substr(i, 1);
        if(is_digital(cur))
        {
            word = cur;
            while(true)
            {
                if(++i == len)
                {
                    word +=" ";
                    dest += word;
                    goto Forend;
                }
                cur = exp.substr(i, 1);
                if(is_digital(cur))
                {
                    word += cur;
                }
                else
                {
                    word +=" ";
                    dest += word;
                    break;
                }
            }
        }
        else if(is_operator(cur))
        {
            if( cur == "(")
            {
                opstk.push( cur );
            }
            else if( cur == ")")
            {
                do
                {
                    opstk.pop(stktop);
                    if(stktop == "(")
                    {
                        break;
                    }
                    dest += stktop;
                }while(true);
            }
            else
            {
                do
                {
                    if(opstk.is_empty())
                    {
                        opstk.push( cur );
                        break;
                    }
                    opstk.get_top(stktop);
                    if(stktop == "(" || 
                        get_priority( cur ) > get_priority(stktop))
                    {
                        opstk.push( cur );
                        break;
                    }
                    else
                    {
                        opstk.pop(stktop);
                        dest +=stktop;
                    }
                }while(true);
            }
            ++i;
        }
        else if(is_space(cur))
        {
            ++i;
        }
        else
        {
            ++i;
        }
    }
    Forend:
    while(!opstk.is_empty())
    {
        opstk.pop(stktop);
        dest += stktop;
    }
    return dest;
}

string itostring(int value, int base)
{
    int i = 30;
    string buf = "";
    for(; value && i ; --i, value /= base)
        buf = "0123456789abcdef"[value % base] + buf;
    return buf;
}

string calc_optr(string op, int a, int b)
{
    string r;
    if(op == "+")
    {
        r=itostring(a+b, 10);
    }
    else if(op == "-")
    {
        r=itostring(a-b, 10);
    }
    else if(op == "*")
    {
        r=itostring(a*b, 10);
    }
    else if(op == "/")
    {
        r=itostring(a/b, 10);
    }
    else if(op == "^")
    {
        int re=1;
        while(b>0)
        {
            re*=a;
            b--;
        }
        r=itostring(re, 10);
    }
    return r;
}

int calc_npr(string & s)
{
    int len = s.length();
    string ch, word;
    MyStack calcstk;
    string popup;
    for(int i=0; i < len; )
    {
        ch = s.substr(i,1);
        if(is_digital(ch))
        {
            word = ch;
            while(true)
            {
                ch = s.substr(++i, 1);
                if(is_digital(ch))
                {
                    word += ch;
                }
                else
                {
                    calcstk.push(word);
                    break;
                }
            }
        }
        else if(is_operator(ch))
        {
            calcstk.pop(popup);
            int b = atoi(popup.c_str());
            calcstk.pop(popup);
            int a = atoi(popup.c_str());
            calcstk.push(calc_optr(ch, a, b));
            i++;
        }
        else
        {
            i++;
        }
    }
    calcstk.pop(popup);
    return atoi(popup.c_str());
}

int main(void)
{
    cout<<"david feng's C practice field"<<endl;
    string expr = "108 - 3^2+ 3*(26-22) + 2  * (10 - 5)";
    string npr_expr;
    while(true)
    {
        cout<<"input an expression to calc\nPress Q to Quit"<<endl;
        cin>>expr;
        if(expr == "q" || expr == "Q")
            break;
        cout<<"Your input is "<<expr<<endl;
        npr_expr = translate_expression(expr);
        cout<<"NPR is "<< npr_expr<<endl;
        cout<<"The result is "<<calc_npr(npr_expr)<<endl<<endl<<endl;
    }
    return 0;
}
struct TNode
{
    string data;
    TNode * lchild;
    TNode * rchild;
};

class BTree
{
public:
    TNode * pRoot;
    bool pre_order_traverse();
    bool in_order_traverse();
    bool post_order_traverse(); 
    void create_btree();
};

