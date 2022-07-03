#coding:utf-8

class DictObject(dict):

#   可以通过属性名来访问的字典类型
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

print EndTaskContent["KillMonsters"]
print EndTaskContent.KillMonsters
print EndTaskContent.ThroughCopy
