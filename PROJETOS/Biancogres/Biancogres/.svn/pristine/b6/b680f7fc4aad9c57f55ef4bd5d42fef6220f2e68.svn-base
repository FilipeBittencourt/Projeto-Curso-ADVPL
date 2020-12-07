#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG061
@author Gabriel Rossi Mafioletti
@since 20/08/2018
@version 1.0
@description Exclusão de Registros de Ponto de Períodos Fechados
@type function

/*/

User Function BIAFG061()

	If !ValidPerg()
		Return
	EndIF

	Processa({||fProcessa()})

Return

Static Function fProcessa()

	Local _aColsPer	:=	{}
	Local _aColsMrk	:=	{}
	
	Local _aHeadPer	:=	{}
	Local _aHeadMrk	:=	{}

	Private oDlg

	Private aObjects	:= {}
	Private aInfo		:=	{}
	Private aSize := MsAdvSize(.F.) //Sem Enchoice
	Private aPosObj	:=	{}

	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aadd(_aHeadPer,{''		  ,'CHECK'     ,'@BMP', 2,0,,	             ,"C",     ,"V",,,'seleciona','V','S'})
	aAdd(_aHeadPer,{"Dt. Ini"         ,"PO_DATAINI" ,"@!"               , 8   , 0,,, "D",, })      	// 1
	aAdd(_aHeadPer,{"Dt. Fim"         ,"PO_DATAFIM" ,"@!"               , 8   , 0,,, "D",, })      	// 1


	aAdd(_aHeadMrk,{"Matrícula"         ,"P8_MAT" ,"@!"               , 6   , 0,,, "C",, })      	// 1
	aAdd(_aHeadMrk,{"Nome"         ,"RA_NOME" ,"@!"               , TAMSX3("RA_NOME")[1]   , 0,,, "C",, })      	// 1
	aAdd(_aHeadMrk,{"Data"         ,"P8_DATA" ,"@!"               , 8   , 0,,, "D",, })      	// 1
	aAdd(_aHeadMrk,{"Hora"         ,"P8_HORA" ,"@!"               , TAMSX3("P8_HORA")[1]   , TAMSX3("P8_HORA")[2],,, "N",, })      	// 1
		

	_aColsPer	:=	fMontaCols()

	If Len(_aColsPer) > 0

		DEFINE MSDIALOG oDlg TITLE "Registros..." FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL STYLE Nor( WS_VISIBLE, WS_POPUP)

		oGetdMrk	:=	MsNewGetDados():New( aPosObj[2][1] + 10, aPosObj[2][2] + 5, aPosObj[2][3] - 5, aPosObj[2][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlg, _aHeadMrk, _aColsMrk )

		oGetdPer	:=	MsNewGetDados():New( aPosObj[1][1] + 10, aPosObj[1][2] + 5, aPosObj[1][3] - 5, aPosObj[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlg, _aHeadPer, _aColsPer, { || fAltPer() } )

		oGetdPer:oBrowse:bLDblClick := {|| oGetdPer:EditCell(), oGetdPer:aCols[oGetdPer:nAt,1] := iif(oGetdPer:aCols[oGetdPer:nAt,1] == 'LBOK','LBNO','LBOK')}

		//@ aPosObj[3][1]+08, aPosObj[3][2]+10 BUTTON oBtClose PROMPT "Marcar/Desmarcar" SIZE 060, 012 OF oDlg ACTION fMarca() PIXEL
		@ aPosObj[3][1]+08, aPosObj[3][4]-040 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION (cj_Fecha := .F., fh_Esc := .T., oDlg:End()) PIXEL
		@ aPosObj[3][1]+08, aPosObj[3][4]-103 BUTTON oBtInt PROMPT "Excluir Seleção"   SIZE 065, 012 OF oDlg ACTION Processa({|| fDelApon() }) PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

	Else

		MsgInfo("Não há itens para serem exibidos!","Aviso")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG061" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}


	MV_PAR01 := SPACE(4)


	aAdd( aPergs ,{1,"Ano Base " 	  				,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.T.})

	If ParamBox(aPergs ,"Exclusão de Registros de Ponto de Períodos Fechados",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet

Static Function fMontaCols()

	Local _cAlias	:=	GetNextAlias()

	Local _aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:SPO%
		WHERE (
				SUBSTRING(PO_DATAINI, 1, 4) = %Exp:MV_PAR01%
				OR SUBSTRING(PO_DATAFIM, 1, 4) = %Exp:MV_PAR01%
				)
			AND PO_FLAGFEC = '0'
			AND %NotDel%

	
	EndSql

	While (_cAlias)->(!EOF())

		aAdd(_aCols,{'LBNO',Stod((_cAlias)->PO_DATAINI),Stod((_cAlias)->PO_DATAFIM),.F.})

		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())

Return _aCols

Static Function fMarca()

	Local _cMarca	:=	""
	Local _nI

	If oGetdPer:aCols[1,1] == "LBOK"
		_cMarca	:=	"LBNO"
	Else
		_cMarca	:=	"LBOK"
	EndIf

	For _nI:=1 to Len(oGetdPer:aCols)

		oGetdPer:aCols[_nI,1]	:=	_cMarca

	Next

	oGetd:Refresh()

Return

Static Function fDelApon()

	Local _nI
	BEGIN TRANSACTION
		For _nI := 1 To Len(oGetdPer:aCols)
	
			If oGetdPer:aCols[_nI,1] == "LBOK"
	
				fDelPer(_nI)
	
			Endif
		Next
	END TRANSACTION
	MsgInfo("Exclusões realizadas com sucesso!")

	
	oDlg:End()
	
Return


Static Function FDelPer(_nI)

	Local _nPosDIni	:=	aScan(oGetdPer:aHeader,{|x| Alltrim(x[2]) == "PO_DATAINI"})
	Local _nPosDFim	:=	aScan(oGetdPer:aHeader,{|x| Alltrim(x[2]) == "PO_DATAFIM"})

	Local _cPeraPon	:=	Dtos(oGetDPer:aCols[_nI,_nPosDIni]) + Dtos(oGetDPer:aCols[_nI,_nPosDFim])

	Local _cAlias	:= GetNextAlias()
	
	BeginSql Alias _cAlias
	

		SELECT SP8.R_E_C_N_O_ REC
		FROM %TABLE:SP8% SP8
		JOIN %TABLE:SRA% SRA ON SP8.P8_FILIAL = %XFILIAL:SP8% 
			AND SP8.P8_FILIAL = SRA.RA_FILIAL
			AND SP8.P8_MAT = SRA.RA_MAT
			AND SP8.P8_PAPONTA = %Exp:_cPeraPon%
			AND SP8.%NotDel%
			AND SRA.%NotDel%
	
	EndSql

	While (_cAlias)->(!EOF())
	
		SP8->(DbGoTo((_cAlias)->REC))
		If SP8->(!EOF())
			RECLOCK("SP8",.F.)
			SP8->(DbDelete())
			SP8->(MsUnlock())
		EndIf
	
		(_cAlias)->(DbSkip())
	
	EndDo

	(_cAlias)->(DbCloseArea())
Return


Static Function FAltPer()

	Local _nPosDIni	:=	aScan(oGetdPer:aHeader,{|x| Alltrim(x[2]) == "PO_DATAINI"})
	Local _nPosDFim	:=	aScan(oGetdPer:aHeader,{|x| Alltrim(x[2]) == "PO_DATAFIM"})

	Local _cPeraPon	:=	Dtos(oGetDPer:aCols[oGetDPer:nAt,_nPosDIni]) + Dtos(oGetDPer:aCols[oGetDPer:nAt,_nPosDFim])

	Local _cAlias	:= GetNextAlias()
	
	Local _aCols	:=	{}


	BeginSql Alias _cAlias
	

		SELECT P8_MAT
			,RA_NOME
			,P8_DATA
			,P8_HORA
			,P8_PAPONTA
		FROM %TABLE:SP8% SP8
		JOIN %TABLE:SRA% SRA ON SP8.P8_FILIAL = %XFILIAL:SP8% 
			AND SP8.P8_FILIAL = SRA.RA_FILIAL
			AND SP8.P8_MAT = SRA.RA_MAT
			AND SP8.P8_PAPONTA = %Exp:_cPeraPon%
			AND SP8.%NotDel%
			AND SRA.%NotDel%
	
	EndSql

	While (_cAlias)->(!EOF())
	
		aAdd(_aCols,{(_cAlias)->P8_MAT,(_cAlias)->RA_NOME,StoD((_cAlias)->P8_DATA),(_cAlias)->P8_HORA,.F.})
	
		(_cAlias)->(DbSkip())
	EndDo

	If Len(_aCols) > 0
		oGetdMrk:aCols	:=	_aCols
		oGetdMrk:Show()
		oGetdMrk:Refresh()
	Else	
		oGetdMrk:aCols	:=	_aCols
		oGetdMrk:Hide()
		oGetdMrk:Refresh()
	EndIf

	(_cAlias)->(DbCloseArea())
Return