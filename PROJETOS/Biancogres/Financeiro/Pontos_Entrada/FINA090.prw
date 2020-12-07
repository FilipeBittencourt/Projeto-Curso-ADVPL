#include "rwmake.ch"
#include "topconn.ch"

User Function FINA090()

IF cEmpAnt == '02'			
   Return
ENDIF    

SetPrvt("WPREFIXO,WNUM,WPARCELA,WTIPO,WFORNECE,WLOJA,CCLVL,CCONTRATO")
SetPrvt("CARQSE2,CINDSE2,CREGSE2,AAREA")
SetPrvt("CARQSE5,CINDSE5,CREGSE5")

aArea     := GetArea()
wAlias    := Alias()

wPrefixo  := SE2->E2_PREFIXO
wNum      := ALLTRIM(SE2->E2_NUM)+SPACE(3)
wParcela  := SE2->E2_PARCELA
wTipo     := SE2->E2_TIPO
wFornece  := SE2->E2_FORNECE
wLoja     := SE2->E2_LOJA
cCLVL     := SPACE(1)           
cContrato := SPACE(6)           

A00 := " SELECT E2_CLVL, E2_YCONTR "
A00 += " FROM "+RetSqlName("SE2")+" SE2 "
A00 += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
A00 += " AND E2_PREFIXO = '"+wPrefixo+"' "
A00 += " AND E2_NUM     = '"+wNum+"' "
A00 += " AND E2_PARCELA = '"+wParcela+"' "
A00 += " AND E2_TIPO    = '"+wTipo+"' "
A00 += " AND E2_FORNECE = '"+wFornece+"' "
A00 += " AND E2_LOJA    = '"+wLoja+"' "
A00 += " AND SE2.D_E_L_E_T_ = ' ' "
If chkfile("A00")
	dbSelectArea("A00")
	dbCloseArea()
EndIf
TcQuery A00 New Alias "A00"

IF !EMPTY(A00->E2_CLVL)
	cCLVL := SE2->E2_CLVL
ENDIF

IF !EMPTY(A00->E2_YCONTR)
	cContrato := SE2->E2_YCONTR
ENDIF

cQuery  := ""
cQuery  += "UPDATE "+RetSQLName("SE5")+" "
cQuery  += "SET "
cQuery  += " E5_CLVLDB = '"+cCLVL+"', "
cQuery  += " E5_YCONTR = '"+cContrato+"' "
cQuery  += "WHERE "
cQuery  += " E5_FILIAL      = '"+xFilial("SE5")+"' "
cQuery  += " AND E5_PREFIXO = '"+wPrefixo+"' "
cQuery  += " AND E5_NUMERO  = '"+wNum+"' "
cQuery  += " AND E5_PARCELA = '"+wParcela+"' "
cQuery  += " AND E5_TIPO    = '"+wTipo+"' "
cQuery  += " AND E5_CLIFOR  = '"+wFornece+"' "
cQuery  += " AND E5_LOJA    = '"+wLoja+"' " 
cQuery  += " AND E5_CLVLDB  = ' ' " 
cQuery  += " AND D_E_L_E_T_ = ' ' "
TCSQLExec(cQuery)

//ATUALIZANDO BANCO / AGENCIA - SF6 - GUIAS 
If Alltrim(SE2->E2_TIPO) == "TX" .And. SUBSTR(SE2->E2_FORNECE,1,4) == "GNRE" .And. Alltrim(SE2->E2_PREFIXO) == "ICM"
	cQuery  := ""
	cQuery  += "UPDATE "+RetSqlName("SF6")+" SET F6_BANCO = '"+SE5->E5_BANCO+"', F6_AGENCIA = '"+SE5->E5_AGENCIA+"' "
	cQuery  += " WHERE F6_NUMERO = '"+SE5->E5_PREFIXO+SE5->E5_NUMERO+"' AND F6_DOC <> '' AND F6_VALOR = '"+Alltrim(Str(SE5->E5_VALOR))+"' AND D_E_L_E_T_ = '' "
	TCSQLExec(cQuery)
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Finalizacao do programa											  										 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea(wAlias)
RestArea(aArea)

Return
