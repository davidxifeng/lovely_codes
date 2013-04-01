#coding:utf-8

class DictObject(dict):
    
    def __getattr__(self,name):
        return self.get(name)
    
    def __setattr__(self,k,v):
        self[k] = v   

EndTaskContent = DictObject({ \
    "KillMonsters"             : 1,    #刷怪
    "ThroughCopy"              : 2,    #通关
    "CollectMaterial"          : 3,    #收集物品
    "BeenTalk"                 : 4,    #对话
})

print type(EndTaskContent)

print EndTaskContent
