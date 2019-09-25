#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"


#Define CRLF chr(13)+chr(10)

/*
##############################################################################################################
# PROGRAMA...: FCACWF01
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 20/05/2015
# DESCRICAO..: WorkFlow de propostas em aberto
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/
User Function FCACWF01()

Local _cSql 
Local cAtend := ""

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"


Conout("______ Executando rotina FCACWF01...")

_cSql:= "SELECT AB3_ATEND, AB3_NUMORC, AB3_EMISSA, AB3_CODCLI+'-'+AB3_LOJA COD_CLI, A1_NOME NOME_CLI, B1_DESC, AB4_NUMSER, AAG_DESCRI, SUM(AB5_TOTAL) AS TOTAL"
_cSql+= CRLF+"	FROM "+RetSqlName("AB3")+" AB3"
_cSql+= CRLF+"			INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_COD=AB3_CODCLI AND A1_LOJA=AB3_LOJA AND SA1.D_E_L_E_T_=' '"
_cSql+= CRLF+"			INNER JOIN "+RetSqlName("AB4")+" AB4 ON AB3_NUMORC=AB4_NUMORC AND AB4.D_E_L_E_T_=' '"  
_cSql+= CRLF+"			INNER JOIN "+RetSqlName("SB1")+" SB1 ON AB4.AB4_CODPRO=SB1.B1_COD AND SB1.D_E_L_E_T_=' '"
_cSql+= CRLF+"			INNER JOIN "+RetSqlName("AAG")+" AAG ON AAG_CODPRB=AB4_CODPRB AND AAG.D_E_L_E_T_=' '"
_cSql+= CRLF+"			INNER JOIN "+RetSqlName("AB5")+" AB5 ON AB5_NUMORC=AB3_NUMORC AND AB5_ITEM=AB4_ITEM AND AB5.D_E_L_E_T_=' '"
_cSql+= CRLF+"	WHERE AB3_STATUS='A' AND DATEDIFF(DAY, AB3_EMISSA,GETDATE())>=7 AND AB3.D_E_L_E_T_=' '" 
_cSql+= CRLF+"	GROUP BY AB3_ATEND, AB3_NUMORC, AB3_EMISSA, AB3_CODCLI,AB3_LOJA, A1_NOME, B1_DESC, AB4_NUMSER, AAG_DESCRI"
_cSql+= CRLF+"	ORDER BY AB3_ATEND, AB3_NUMORC, AB3_CODCLI,AB3_LOJA"

If select ("TRB")>0
	TRB->(DbCloseArea())
Endif

TCQUERY _cSql NEW ALIAS "TRB"

cMsgIni :='<html>'
cMsgIni +='<head>'
cMsgIni +='<title>Orcamentos em aberto</title>'
cMsgIni +='</head>'
cMsgIni +='<body>'
cMsgIni += '<table border="1">'

cMsgIni += '  <tr>'
cMsgIni += '    <th >Orçamento  </th>'
cMsgIni += '    <th >Data    </th>'
cMsgIni += '    <th >Cliente    </th>'
cMsgIni += '    <th >Produto    </th>'
cMsgIni += '    <th >ID Único   </th>'
cMsgIni += '    <th >Descrição  </th>'
cMsgIni += '    <th >Valor  </th>'
cMsgIni += '  </tr>'

cMsg := cMsgIni
While !TRB->(Eof())
	cAtend := TRB->AB3_ATEND
	cMsg += '  <tr>'
	cMsg += '    <td >'+Alltrim(TRB->AB3_NUMORC)+'</td>'
	cMsg += '    <td >'+Alltrim(dtoc(STOD(AB3_EMISSA)))+'</td>'
	cMsg += '    <td >'+Alltrim(TRB->NOME_CLI)+'</td>'
	cMsg += '    <td >'+Alltrim(TRB->B1_DESC)+'</td>'
	cMsg += '    <td >'+Alltrim(TRB->AB4_NUMSER)+'</td>'
	cMsg += '    <td >'+Alltrim(TRB->AAG_DESCRI)+'</td>'
	cMsg += '    <td >'+STR(TRB->TOTAL,10,2)+'</td>'
	cMsg += '  </tr>'
	
	TRB->(DbSkip())
	
	If TRB->(Eof()) .or. TRB->AB3_ATEND != cAtend
		cMsg += '</table>' 
		cMsg +='</body>'
		cMsg +='</html>'
		
		_aTO := {emailUsr(Alltrim(cAtend))}
		_aCC := {}
		_aCCO:= {}
		_cSUBJECT:= "Propostas em aberto "+ALLTRIM(cAtend)+" "+dtoc(date())+" "+Time()
		_cBODY:=  cMsg 
		_aAnexo:={}
		
		U_SendMail(_aTO,_aCC,_aCCO,_cSUBJECT,_cBODY)
		
		cMsg := cMsgIni
	Endif
Enddo
TRB->(DbCloseArea())

Return 



Static function emailUsr(cAtend)

Local nPosUser := 0
Local aUser    := {}
Local aUsers   := AllUsers(.F., .T.)
Local cMail	:= ""
    
nPosUser := aScan(aUsers, {|x| Upper(AllTrim(cAtend)) $ Upper(AllTrim(x[01, 04])) })
If nPosUser > 0
	aUser := aUsers[nPosUser]			
EndIf

if len(aUser)>0
	cMail := AllTrim(aUser[1, 14])
endif

Return cMail
