#include "totvs.ch" 


/*/{Protheus.doc} CHKEXEC
@description Ponto de Entrada na execução de qualquer função do MENU
@author Fernando Rocha
@since 19/07/2017
@version undefined
@type function
/*/
User Function CHKEXEC() 

Local lRet      := .T. 
Local cSQL

Local cFuncao 	:= SubStr(ParamIXB, 1, At('(',ParamIXB)-1 ) 
Local cTipo		:= IIF ( ExistBlock(cFuncao, , .T.) , "CUSTOMIZADA" , "PADRAO" )


cSQL := " INSERT INTO LOG_USO_ROTINA "+CRLF
cSQL += " (FUNCAO, TIPO, USUARIO, USERID, COMPUTERNAME, LOGUSERNAME, MODULO , MENUFILE, DATA, HORA) "+CRLF
cSQL += " VALUES "+CRLF
cSQL += " ( "+CRLF
cSQL += " '"+cFuncao+"', "+CRLF
cSQL += " '"+cTipo+"', "+CRLF
cSQL += " '"+CUSERNAME+"', "+CRLF
cSQL += " '"+__CUSERID+"', "+CRLF
cSQL += " '"+ComputerName()+"', "+CRLF
cSQL += " '"+LogUserName()+"', "+CRLF
cSQL += " '"+CMODULO+"', "+CRLF
cSQL += " '"+FWGetMnuFile()+"', "+CRLF
cSQL += " '"+DTOS(Date())+"', "+CRLF
cSQL += " '"+SUBSTR(Time(),1,8)+"' "+CRLF
cSQL += " ) "+CRLF

TCSQLExec(cSQL)

Return(lRet) 