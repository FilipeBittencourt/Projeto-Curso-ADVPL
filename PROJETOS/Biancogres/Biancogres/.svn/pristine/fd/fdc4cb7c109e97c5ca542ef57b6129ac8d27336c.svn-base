#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPE550ICD  บAutor  ณ Ranisses A. Corona บ Data ณ  03/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acerta                                         							บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GPE550ICD()

Local _aBenef := aClone( ParamIxb[1] )
Local nPos		:= ASCAN(_aBenef,{|X| X[10]=="406"})
Local cSql		:= ""                   

If nPos <> 0
	
	If cEmpAnt == "01"
		dbSelectArea("GPRATAM01")
		dbGoTop("GPRATAM01")	
		ADEL(_aBenef,nPos)
		ASIZE(_aBenef,Len(_aBenef)-1)		
		While !GPRATAM01->(EOF())
			If GPRATAM01->MATFUNC == SRA->RA_MAT .AND. GPRATAM01->MES $ ("01_02")	.AND. GPRATAM01->ANO == "2010"
				If Alltrim(GPRATAM01->CODDEP) == ""
					nQuant	:= Len(_aBenef)
					AADD(_aBenef,{"ASS MEDICA TITULAR             - TITULAR - CASA DE SAUDE SAO BERNARDO LTDA - CNPJ: 31.488.208/0002-06","31488208000206","","","","","","",GPRATAM01->VALOR,"406","R","",.F.,"","","TMED" })
				Else
					cSql := ""
					cSql := "SELECT * FROM "+RetSqlName("SRB")+" WHERE RB_MAT = '"+SRA->RA_MAT+"' AND RB_COD = '"+GPRATAM01->CODDEP+"' AND D_E_L_E_T_ = '' "
					If chkfile("_SRB")
						dbSelectArea("_SRB")
						dbCloseArea()
					EndIf
					TCQUERY cSql ALIAS "_SRB" NEW
					dbSelectArea("_SRB")
					dbGotop("_SRB")				
					AADD(_aBenef,{Alltrim(_SRB->RB_NOME)+" / CPF: "+Alltrim(_SRB->RB_CIC)+" - Ass.Medica Dep. - CASA DE SAUDE SAO BERNARDO LTDA - CNPJ: 31.488.208/0002-06","31488208000206","","","","","","",GPRATAM01->VALOR,"X"+_SRB->RB_COD,"R","",.F.,"","",_SRB->RB_GRAUPAR+"MED"+_SRB->RB_COD })
				EndIf
			EndIf
			GPRATAM01->(DbSkip())
		EndDo
	Else
		dbSelectArea("GPRATAM05")
		dbGoTop("GPRATAM05")
		
		ADEL(_aBenef,nPos)
		ASIZE(_aBenef,Len(_aBenef)-1)
		
		While !GPRATAM05->(EOF())
			If GPRATAM05->MATFUNC == SRA->RA_MAT .AND. GPRATAM05->MES $ ("01_02")			
				If Alltrim(GPRATAM05->CODDEP) == ""
					nQuant	:= Len(_aBenef)
					AADD(_aBenef,{"ASS MEDICA TITULAR             - TITULAR - CASA DE SAUDE SAO BERNARDO LTDA - CNPJ: 31.488.208/0002-06","31488208000206","","","","","","",GPRATAM05->VALOR,"406","R","",.F.,"","","TMED" })
				Else
					cSql := ""
					cSql := "SELECT * FROM "+RetSqlName("SRB")+" WHERE RB_MAT = '"+SRA->RA_MAT+"' AND RB_COD = '"+GPRATAM05->CODDEP+"' AND D_E_L_E_T_ = '' "
					If chkfile("_SRB")
						dbSelectArea("_SRB")
						dbCloseArea()
					EndIf
					TCQUERY cSql ALIAS "_SRB" NEW
					dbSelectArea("_SRB")
					dbGotop("_SRB")
					
					AADD(_aBenef,{Alltrim(_SRB->RB_NOME)+" / CPF: "+Alltrim(_SRB->RB_CIC)+" - Ass.Medica Dep. - CASA DE SAUDE SAO BERNARDO LTDA - CNPJ: 31.488.208/0002-06","31488208000206","","","","","","",GPRATAM05->VALOR,"X"+_SRB->RB_COD,"R","",.F.,"","",_SRB->RB_GRAUPAR+"MED"+_SRB->RB_COD })
				EndIf
			EndIf
			GPRATAM05->(DbSkip())
		EndDo	
	EndIf
EndIf

Return( aClone( _aBenef ) ) 
