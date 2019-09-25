#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"


#Define CRLF chr(13)+chr(10)

/*
##############################################################################################################
# PROGRAMA...: FCACWF02
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 30/06/2015
# DESCRICAO..: WorkFlow de Alerta de Manutenção Preventiva
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/
User Function FCACWF02()

Local _cSql 
Local cAtend := ""
Local nHorimAtu
Local nProxManut
Local nDiasAviso
Local cDestMail

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

nDiasAviso := GetNewPar("FA_WF02DIA",30)
cDestMail	:= AllTrim(GetNewPar("FA_WF02DML", "gustavo@centraldearcomprimido.com.br;wagner@centraldearcomprimido.com.br"))

Conout("______ Executando rotina FCACWF02...")

cMsgIni :='<html>'
cMsgIni +='<head>'
cMsgIni +='<title>Manutenções Preventivas Previstas</title>'
cMsgIni +='</head>'
cMsgIni +='<body>' 
cMsgIni +='<h1>Manutenções Preventivas Previstas - Próximos '+alltrim(str(nDiasAviso))+' dias</h1>'
cMsgIni += '<table border="1">'
cMsgIni += '  <tr>'  
cMsgIni += '    <th >Cliente      </th>'
cMsgIni += '    <th >Produto      </th>'
cMsgIni += '    <th >ID Único     </th>'
cMsgIni += '    <th >Horím. Atual </th>'
cMsgIni += '    <th >Revisão      </th>'
cMsgIni += '    <th >Data Prevista</th>'
cMsgIni += '  </tr>'

cMsg := cMsgIni 

DbSelectArea("AA3")
AA3->(DbSetOrder(1)) 

DbSelectArea("SZ4")
SZ4->(DbSetOrder(1))

While !AA3->(Eof())
	If .not. SZ4->(DbSeek(xFilial("SZ4")+AA3->AA3_CODPRO))
		AA3->(DbSkip())
		loop
	Else
		nHorimAtu := U_calcHori(DATE(),IIF(EMPTY(AA3->AA3_YDTHOR),AA3->AA3_DTVEND,AA3->AA3_YDTHOR), AA3->AA3_HORDIA,AA3->AA3_DIAOPE,AA3->AA3_YHORIM)
		While !SZ4->(Eof()) .and. SZ4->Z4_PRODUTO == AA3->AA3_CODPRO .and. SZ4->Z4_HORAS < nHorimAtu
			SZ4->(DbSkip())
		EndDo
		If !SZ4->(Eof()) .and. SZ4->Z4_PRODUTO == AA3->AA3_CODPRO 
			nProxManut := SZ4->Z4_HORAS
			nMediaDia  := (AA3->AA3_HORDIA*AA3->AA3_DIAOPE)/7  
			nDiasManut := (nProxManut-nHorimAtu) / nMediaDia
			if nDiasManut <= nDiasAviso
				dDataManut := date() + nDiasManut
				
				cMsg += '  <tr>'
				cMsg += '    <td >'+AA3->AA3_CODCLI+"/"+AA3->AA3_LOJA+" - "+Alltrim(Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_NOME"))+'</td>'
				cMsg += '    <td >'+Alltrim(AA3->AA3_CODPRO)+" - "+Alltrim(Posicione("SB1", 1, xFilial("SB1")+AA3->AA3_CODPRO, "B1_DESC"))+'</td>'
				cMsg += '    <td >'+Alltrim(AA3->AA3_NUMSER)+'</td>'
				cMsg += '    <td >'+STR(NOROUND(nHorimAtu,0))+'</td>'
				cMsg += '    <td >'+STR(nProxManut)+'</td>'
				cMsg += '    <td >'+dtoc(dDataManut)+'</td>'
				cMsg += '  </tr>'
			endif
		EndIf
	Endif
	
	AA3->(DbSkip())
EndDo

cMsg += '</table>'
cMsg +='</body>'
cMsg +='</html>'  

_aTO := {cDestMail}
_aCC := {}
_aCCO:= {}
_cSUBJECT:= "Alerta de Manutenção Preventiva "+dtoc(date())+" "+Time()
_cBODY:=  cMsg 
_aAnexo:={}
		
U_SendMail(_aTO,_aCC,_aCCO,_cSUBJECT,_cBODY)

Return 
