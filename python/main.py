
import antlr4
from antlr4.InputStream import InputStream
from antlr4.FileStream import FileStream

from parser.ROSMsg_Lexer import ROSMsg_Lexer
from parser.ROSMsg_ParserListener import ROSMsg_ParserListener
from parser.ROSMsg_Parser import ROSMsg_Parser

import sys

class ROSMsg_Listener(ROSMsg_ParserListener):
    

    def enterRos_message(self, ctx:ROSMsg_Parser.Ros_messageContext):
        
       if (len(ctx.field_declaration())): 
        print("This is a field declaration")
        
        if (len(ctx.comment())):
            print("Comment was included")
            for comment in ctx.comment():
                print(comment.COMMENT().getText())

            fields = ctx.field_declaration()
            print(len(fields))
            for f in fields: 
                print (f"Identifier: [{f.identifier().getText()}] Type: [{f.type_def().getText()}]")   


        if ctx.field_declaration()[1].array_type(): 
            print("This is an array")
            


    def parseType(self, typeName:str, dir:str): 
        ret:int 
        fqType:str = ""

        fqType = dir
        if not fqType.endswith('/'):
            fqType += '/'
    
        fqType += typeName
        fqType += ".msg"
        
            
def main():
    input_stream = FileStream("test/msg/Twist.msg")
#    file = open(, "r", encoding="utf-8")
    lexer = ROSMsg_Lexer(input_stream)
    stream = antlr4.CommonTokenStream(lexer)
    parser = ROSMsg_Parser(stream)
    tree = parser.ros_file_input()
    printer = ROSMsg_Listener()
    walker = antlr4.ParseTreeWalker()
    walker.walk(printer, tree)

if __name__ == '__main__':
    main()