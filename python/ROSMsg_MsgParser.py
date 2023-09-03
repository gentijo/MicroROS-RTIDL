import logging
import io
import csv
import sys
import os
import  antlr4
from    antlr4.FileStream import FileStream
from    antlr4.InputStream import InputStream

from parser.ROSMsg_Lexer import ROSMsg_Lexer
from parser.ROSMsg_ParserListener import ROSMsg_ParserListener
from parser.ROSMsg_Parser import ROSMsg_Parser

from github import Github 
from github import Auth
from github import ContentFile

ghtoken:str = os.getenv('ROSTYPE_GITHUB_PAT')


class ROSMsg_TypeCatalog:
    
    def __init__(self, repoName:str="ros2/common_interfaces", branchName:str="galactic", token:str=""):
        
        if (not token): token =""
        
        auth = Auth.Token(token)
        self.github = Github(auth=auth)
        self.github.get_user().login
        self.repo = self.github.get_repo(repoName)
        self.repo.get_branch(branchName)
        self.locatorMapByPath = {}
        self.locatorMap_TypeIdx = {}
        self.ROSMsg_Listener = ROSMsg_Listener()
        self.typeDefObjCache:dict = {}
        
    #
    #
    #  
    def catalogMsgFiles(self, cacheFile:str="", forceUpdate:bool=False):
#        str(self.repo.pushed_at)
        self.locatorMapByPath.clear()
        self.locatorMap_TypeIdx.clear()
        if ( not self.readTypesFromCache(cacheFile=cacheFile, forceUpdate=forceUpdate) ):
            self.readTypesFromGithubAPI()
            self.updateCacheFile(cacheFile=cacheFile)


    #
    #
    #
    def readTypesFromCache(self, cacheFile:str="", forceUpdate:bool=False) -> int:
        #
        # Read in the cache file, but check to see if the Repo changed or not
        # using the etag field.
        #
        
        file = None
        try:
            typesFound:int = 0
            if cacheFile and not forceUpdate:
                file = open(cacheFile, "r", encoding="utf-8")
                reader = csv.reader(file)
   
                record:str = reader.__next__()
                if record[0] == self.repo.etag:
                    for record in reader:
                        if (len(record) >= 3):
                            path = record[0]
                            typeName = record[1]
                            lastUpdate = record[2]
                            
                            self.catalogTypeLocator(path=path, typeName=typeName, lastUpdate=lastUpdate)
                            typesFound = typesFound+1
                        
            return len(self.locatorMap_TypeIdx)

        except Exception as exc:
            self.locatorMapByPath.clear()
            self.locatorMap_TypeIdx.clear()
      
      
        try:           
            if (file): 
                file.close()
                file = None
        except: 
            file = None
            pass 
        
    #
    #
    #
    def readTypesFromGithubAPI(self):   
        #
        # We are here because no cache or a problem reading cache
        #
        try:
            contents = self.repo.get_contents("")
            
            while contents:
                file_content = contents.pop(0)
                if file_content.type == "dir":
                    contents.extend(self.repo.get_contents(file_content.path))
                else:
                    if file_content.path.endswith(".msg"):
                        
                        update_date = file_content.etag

                        path = file_content.path
                        idx1 = path.rfind('/')
                        idx2 = path.rfind('.')
                        if not (idx1 == -1) and not ( idx2 == -1):
                            typeName = path[idx1+1:idx2]
                        else:
                            typeName = path
                        
                        self.catalogTypeLocator(path=path, typeName=typeName, lastUpdate=update_date)
                        
        except Exception as exc:
            pass
                    
    #
    # Write the current type locator map to the cache file
    #
    def updateCacheFile(self, cacheFile=""):
        #
        # If we want to Cache files, dump the contents to a csv file
        #
        
        file = None
        if (cacheFile and len(self.locatorMapByPath)):
            try:       
                file = open(cacheFile, "w", encoding="utf-8")

                csvWriter = csv.writer(file)
                csvWriter.writerow([self.repo.etag])
                keys = self.locatorMapByPath.keys()
                for key in keys:
                    record = self.locatorMapByPath[key]
                    csvWriter.writerow(record)
                    
            except Exception as exc:
                pass
            
        try:
            if file:
                file.close()
                file = None
        except:
            file = None
            
            
    #
    # add an entry to the type locator catalog, the type locator stores the path, Typename and last update date
    # in a map indexed by  both the path and type name. 
    #
    # This will be used to locate the raw data to be parsed, the parsed data will be stored in type map
    #
    def catalogTypeLocator(self, path:str, typeName:str, lastUpdate:str):
        self.locatorMapByPath[path] = [path, typeName, lastUpdate]
        self.locatorMap_TypeIdx[typeName]=path

    #
    #
    #
    def getTypeDefinitionText(self, type_or_path:str) -> str:
        
        fcontents = None
        try:
            if type_or_path in self.locatorMapByPath:
                fcontents = self.repo.get_contents(type_or_path)
            elif type_or_path in self.locatorMap_TypeIdx:
                path = self.locatorMap_TypeIdx[type_or_path]
                fcontents = self.repo.get_contents(path)
                
        except Exception as exc:
            return ""
                    
        if fcontents:
            return fcontents.decoded_content.decode('UTF-8')
        else:
            return ""
            
        
    #
    # Using the Content from the GitHub record, parse the text and cache the result
    #
    def getTypeDefinitionObj(self, typeName_or_path ) -> list:
        typeDef:list = []
        self.ROSMsg_Listener.setCurrentTypeDef(typeDef)
        
        content = self.getTypeDefinitionText(typeName_or_path)
        
        lexer = ROSMsg_Lexer(InputStream(content))
        stream = antlr4.CommonTokenStream(lexer)
        parser = ROSMsg_Parser(stream)
        tree = parser.ros_file_input()
        walker = antlr4.ParseTreeWalker()
        walker.walk(self.ROSMsg_Listener, tree)
        self.typeDefObjCache[typeName_or_path] = typeDef
        
        # don't allow future parses to modify the current typeDef Onj
        self.ROSMsg_Listener.setCurrentTypeDef(None)
        
        return typeDef

        
           
class ROSMsg_Listener(ROSMsg_ParserListener):
    
    def setCurrentTypeDef(self, typeDef:list) -> list:
        self.currentTypeDef:list = typeDef
        

    def enterRos_message(self, ctx:ROSMsg_Parser.Ros_messageContext):
        try:
            if (len(ctx.field_declaration())): 
                print("This is a field declaration")
        
                if (len(ctx.comment())):
                    print("Comment was included")
                    for comment in ctx.comment():
                        print(comment.COMMENT().getText())

                    fields = ctx.field_declaration()
                    print(len(fields))
            
                    typeObj:list = []
                    for f in fields: 
                        print (f"Identifier: [{f.identifier().getText()}] Type: [{f.type_def().getText()}]")
                        self.currentTypeDef.append([f.identifier().getText(), f.type_def().getText() ])
                    
        except Exception as exc:
            pass


        if ctx.field_declaration()[1].array_type(): 
            print("This is an array")
            


if __name__ == '__main__':
    rosCatalog = ROSMsg_TypeCatalog(token=ghtoken)
    rosCatalog.catalogMsgFiles(cacheFile="MsgTypeCache.csv", forceUpdate=False)
    print(rosCatalog.getTypeDefinitionText("Twist"))
    twistObj = rosCatalog.getTypeDefinitionObj("Twist")
    print(twistObj)