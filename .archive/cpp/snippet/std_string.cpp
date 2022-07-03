#include <iostream>
#include <string>

using namespace std;

//note: default arg of stl functions;
//string::npos (-1)
//find_last_of 语义 match *any* of the chars in the arguments

int main(int argc, char * argv[]) {
    string s = "/home/david/love";
    cout<<s<<endl;
    string t = s.substr(s.find_last_of("/") + 1);
    cout<<t<<endl;
    cout<<"last of is "<<s.find_last_of("home")<<endl;
    //output 15
    cout<<"last of is "<<s.find_last_of("$$$d")<<endl;
    //output 10
    return 0;
}
