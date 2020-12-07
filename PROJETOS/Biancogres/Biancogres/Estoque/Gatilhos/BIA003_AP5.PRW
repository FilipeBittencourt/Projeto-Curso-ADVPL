#include "TOTVS.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA003
@description GATILHO DO B1_GRUPO ==>Determina o Codigo do Produto e Grava Campos Obrigatorios para produtos PA	
@author Desconhecido - Revisao por Fernando Rocha na versao 25
@since 17/12/2019
@version 1.0
@type function
/*/
User Function BIA003()

	Local oModel := FwModelActive()
	Local oModelSB1 := oModel:getModel('SB1MASTER')

	Private wAlias  := Alias()
	Private wNewCod := M->B1_COD
	Private wGrupo  := SUBS(M->B1_GRUPO,1,3)
	Private wDesc	:= M->B1_DESC
	Private wYRef	:= M->B1_YREF
	Private wYRefPv	:= M->B1_YREFPV
	Private wTipo   := M->B1_TIPO
	Private wLocPad := M->B1_LOCPAD
	Private wConv   := M->B1_CONV
	Private wYDivPa := M->B1_YDIVPA
	Private wYPeca  := M->B1_YPECA
	Private wPeso   := M->B1_PESO
	Private wYPesEmb:= M->B1_YPESEMB
	Private wUm     := M->B1_UM
	Private wSegum  := M->B1_SEGUM
	Private wTipConv:= M->B1_TIPCONV
	Private wConta  := M->B1_CONTA
	Private wPosIpi := M->B1_POSIPI
	Private wIPI    := M->B1_IPI
	Private wClasFis:= M->B1_CLASFIS
	Private wYTipo  := M->B1_YTIPO
	Private wYPolit := M->B1_YPOLIT
	Private wYCtaRes:= M->B1_YCTARES
	//Private wYMono  := M->B1_YMONO
	Private wGrTrib	:= M->B1_GRTRIB

	Private wFormat := M->B1_YFORMAT
	Private wFator	:= M->B1_YFATOR
	Private wClasse := M->B1_YCLASSE
	Private wLinha	:= M->B1_YLINHA
	Private wCodAnt := M->B1_YCODANT

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)

	//define código
	wNewCod := U_proxCod (wNewCod,wGrupo,Inclui,"PR")

	//Grava Campos Padroes quando o produto for PA
	If Alltrim(wGrupo) == "PA"


		oModelSB1:SetValue("B1_TIPO","PA")
		oModelSB1:SetValue("B1_UM","M2")
		oModelSB1:SetValue("B1_SEGUM","CX")
		oModelSB1:SetValue("B1_TIPCONV","D")
		oModelSB1:SetValue("B1_CONTA","11306001")
		oModelSB1:SetValue("B1_FECP",1.00)
		oModelSB1:SetValue("B1_APROPRI","D")


		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(xFilial("SB1")+M->B1_YFORMAT+M->B1_YFATOR+M->B1_YLINHA+M->B1_YCLASSE,.F.))

			oModelSB1:SetValue("B1_DESC", SB1->B1_DESC)
			oModelSB1:SetValue("B1_YREF", SB1->B1_YREF)
			oModelSB1:SetValue("B1_YREFPV", SB1->B1_YREFPV)
		ELSE
		  	
		  	//oModelSB1:SetValue("B1_DESC", "TESTE")
		  	oModelSB1:ClearField("B1_DESC", SB1->B1_DESC)
			oModelSB1:SetValue("B1_YREF", SB1->B1_YREF)
			oModelSB1:SetValue("B1_YREFPV", SB1->B1_YREFPV)

		ENDIF			

		ZZ6->(DbSetOrder(1))
		IF ZZ6->(DbSeek(xFilial("ZZ6")+M->B1_YFORMAT))

			If ZZ6->ZZ6_FORNOP $ "F04/F05"

				oModelSB1:SetValue("B1_LOCPAD", "04")

			Else

				oModelSB1:SetValue("B1_LOCPAD", "02")

			EndIf

			oModelSB1:SetValue("B1_YTPPROD", ZZ6->ZZ6_TPPROD)

		ENDIF		


		DO CASE                      
			CASE M->B1_YFORMAT == 'AC' 
			oModelSB1:SetValue("B1_GRTRIB", "004")			

			CASE SUBSTRING(M->B1_COD,1,1) == ' ' .AND. M->B1_TIPO == 'PA'
			oModelSB1:SetValue("B1_GRTRIB", "000")

			CASE Alltrim(M->B1_COD) == '1010147'	//OS 3992-16 - Tania
			oModelSB1:SetValue("B1_GRTRIB", "101")	

			CASE Alltrim(M->B1_COD) == '2018318' .Or. Alltrim(M->B1_COD) == '2018319' //OS 3417-16 - Tania
			oModelSB1:SetValue("B1_GRTRIB", "201")

			CASE Alltrim(M->B1_COD) $ '2170266/2170294/2171120/2171510/2173256/2173296/2173479/2174242/2175638' //OS 4277-16 - Tania
			oModelSB1:SetValue("B1_GRTRIB", "217")

			CASE SUBSTR(M->B1_COD,8,1) == '5' .OR. SUBSTR(M->B1_DESC,1,4) == 'CACO'
			oModelSB1:SetValue("B1_CLASFIS", "D")
			oModelSB1:SetValue("B1_POSIPI", "25309090")
			oModelSB1:SetValue("B1_GRTRIB", "002")

			CASE SUBSTR(M->B1_YFORMAT,1,1) == 'I'
			oModelSB1:SetValue("B1_CLASFIS", "A")
			oModelSB1:SetValue("B1_POSIPI", "69089000")
			oModelSB1:SetValue("B1_GRTRIB", "003")

			CASE SUBSTRING(M->B1_COD,1,1) <> ' ' .AND. M->B1_TIPO == 'PA'
			oModelSB1:SetValue("B1_CLASFIS", "A")
			oModelSB1:SetValue("B1_POSIPI", "69089000")
			oModelSB1:SetValue("B1_GRTRIB", "001")

			CASE M->B1_YFORMAT == 'BD' 
			oModelSB1:SetValue("B1_CLASFIS", "A")
			oModelSB1:SetValue("B1_POSIPI", "69079000")
			oModelSB1:SetValue("B1_GRTRIB", "001")

		ENDCASE

		//Alteração conforme OS 4094-15 (Código CEST)
		DO CASE  

			CASE Substr(Alltrim(M->B1_POSIPI),1,4) == '3922'
			oModelSB1:SetValue("B1_CEST", "1001300")

			CASE Substr(Alltrim(M->B1_POSIPI),1,4) == '6907'
			oModelSB1:SetValue("B1_CEST", "1003000")

			CASE Substr(Alltrim(M->B1_POSIPI),1,4) == '6908'
			oModelSB1:SetValue("B1_CEST", "1003000")

			CASE Substr(Alltrim(M->B1_POSIPI),1,4) == '6910'
			oModelSB1:SetValue("B1_CEST", "1003100")

		ENDCASE

		oModelSB1:SetValue("B1_IPI", 0.00)
		oModelSB1:SetValue("B1_YTIPO", "P")
		oModelSB1:SetValue("B1_YPOLIT", "0")
		oModelSB1:SetValue("B1_YCTARES", "")

	Else

		oModelSB1:SetValue("B1_DESC",wDesc)
		oModelSB1:SetValue("B1_YREF",wYRef)
		oModelSB1:SetValue("B1_YREFPV",wYRefPv)
		oModelSB1:SetValue("B1_YVLCVP",0)
		oModelSB1:SetValue("B1_TIPO",wTipo)
		oModelSB1:SetValue("B1_LOCPAD",wLocPad)
		oModelSB1:SetValue("B1_CONV",wConv)
		oModelSB1:SetValue("B1_YPECA",wYPeca)
		oModelSB1:SetValue("B1_YDIVPA",wYDivPa)
		oModelSB1:SetValue("B1_PESO",wPeso)
		oModelSB1:SetValue("B1_YPESEMB",wYPesEmb)
		oModelSB1:SetValue("B1_UM",wUm)
		oModelSB1:SetValue("B1_SEGUM",wSegum)
		oModelSB1:SetValue("B1_TIPCONV",wTipConv)
		oModelSB1:SetValue("B1_CONTA",wConta)
		oModelSB1:SetValue("B1_POSIPI",wPosIpi)
		oModelSB1:SetValue("B1_IPI",wIPI)
		oModelSB1:SetValue("B1_CLASFIS","00")
		oModelSB1:SetValue("B1_YTIPO",wYTipo)
		oModelSB1:SetValue("B1_YPOLIT",wYPolit)
		oModelSB1:SetValue("B1_YCTARES",wYCtaRes)
		oModelSB1:SetValue("B1_GRTRIB",wGrTrib)

		IF ALLTRIM(Substr(M->B1_GRUPO,1,3)) == '101'
			oModelSB1:SetValue("B1_YTPPROD","AR")
		ENDIF

		IF ALLTRIM(Substr(M->B1_GRUPO,1,3)) == '104'
			oModelSB1:SetValue("B1_YTPPROD","ME")
		ENDIF

	EndIf

	//Volta area de Trabalho
	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(wNewCod)


/*/{Protheus.doc} proxCod
@description Geracao de codigo de produto
@author ferna
@since 17/12/2019
@version 1.0
@type function
/*/
User Function proxCod(sCod,sGrupo,bInclui,sOrigem)

	If sOrigem == "WS"
		DbSelectArea("SB1")
		cArqSB1 := Alias()
		cIndSB1 := IndexOrd()
		cRegSB1 := Recno()
		DbSetOrder(1)
	EndIf

	// Implementado por Marcos Alberto em 02/08/10 para atender a necessidade de Classificação do Produto Esmalte por tipo separadamente.
	If sGrupo $ "PI02/PI03/PI04"
		sGrupo := "102"
	EndIf

	//Gera codigo do Produto de acordo com o Grupo
	If (LEN(ALLTRIM(sCod))==3) .AND. bInclui
		sCod := ""
		If ! DbSeek(xFilial("SB1")+sGrupo,.t.)

			If Subs(SB1->B1_COD,1,3)==sGrupo
				sCod := Str(Val(Alltrim(SB1->B1_COD)),7,0)
			Else
				Do While ! Bof() .And. Subs(Alltrim(SB1->B1_COD),1,3)<>sGrupo
					dbSkip(-1)
				EndDo
				If Bof()
					sCod := sGrupo+"0000"
				EndIf
			EndIf

		Else
			Do While ! Eof() .And. SUBS(SB1->B1_COD,1,3)==sGrupo
				dbSkip()
			EndDo
			dbSkip(-1)

			If SUBS(SB1->B1_COD,1,3)==sGrupo

				sCod := SUBS(SB1->B1_COD,1,3) + Soma1(Subs(SB1->B1_COD,4,4))

			EndIf
		EndIf
	EndIF

Return sCod