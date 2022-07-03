#include <string>
#include <iostream>

using namespace std;

int find( const std::string& surname
        , const std::string& givenName
        , bool retired = false) {
    cout << "find a" << endl;
    return 1;
}

#if 1
int find(const std::string& fullName, bool retired = false) {
    cout << "find b" << endl;
    return 0;
}
#endif

int main() {
    find("a", "b"); // b
    find("a", NULL); // warning b
    return 0;
}
