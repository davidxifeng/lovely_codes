#include <ext/hash_map>

#include <iostream>

using namespace std;
using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash<std::string>
    {
        size_t operator()(const std::string & x)const{
            return hash<const char*>()(x.c_str());
        }
    };
    template<> struct hash<long long>
    {
        size_t operator()(long long l)const{
            return l;
        }
    };
}

#define sk 1
#if sk
//typedef hash_map<const char *, int> str2int_hmap;
//typedef hash_map<const char *, int>::iterator str2int_hmap_iter;
typedef hash_map<string, int> str2int_hmap;
typedef hash_map<string, int>::iterator str2int_hmap_iter;
#else
typedef hash_map<int, int> str2int_hmap;
typedef hash_map<int, int>::iterator str2int_hmap_iter;
#endif
int unit_main(void) {
    str2int_hmap am;
#if sk
    am.insert(make_pair("jack", 1));
    am.insert(make_pair("lucy", 4));
    am.insert(make_pair("love", 5));
    am.insert(make_pair("you", 6));
    am.insert(make_pair("grace", 7));
    str2int_hmap_iter it = am.find("love");
#else
    am.insert(make_pair(6, 4));
    am.insert(make_pair(9, 1));
    str2int_hmap_iter it = am.find(9);
#endif
    if(it != am.end()){
        cout<<"first find is "<<it->second<<" "<<endl;
    }
    //it = am.begin();
    for(; it != am.end(); ){
        if(it->second == 5){
            am.erase(it++);
        }else {
            it++;
        }
    }
    cout<<"is empty? "<<am.empty()<<endl;
    it = am.begin();
    for(; it != am.end(); it++) {
        cout<<it->second<<":"<<endl;;
    }
    cout<<"is empty? "<<am.empty()<<endl;
    return 0;
}
