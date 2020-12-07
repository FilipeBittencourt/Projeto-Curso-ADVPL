#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG060
@author Gabriel Rossi Mafioletti
@since 20/08/2018
@version 1.0
@description Rotina Para Re-Envio de Solicitações de Amostra para o Ecosis
@type function

/*/

User Function BIAFG060()

	Private _cEmpresa

	Do Case
		Case cEmpAnt == "01"
		_cEmpresa	:= "0101"
		OtherWise
		Return
	EndCase

	If !ValidPerg()
		Return
	EndIf

	Processa({||fProcessa()})

Return

Static Function fProcessa()

	Local _aCols	:=	{}
	Local _aHeader	:=	{}

	Private oDlg

	Private aObjects	:= {}
	Private aInfo		:=	{}
	Private aSize := MsAdvSize(.F.) //Sem Enchoice
	Private aPosObj	:=	{}

	AAdd( aObjects, { 100, 400, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aadd(_aHeader,{''		  ,'CHECK'     ,'@BMP', 2,0,,	             ,"C",     ,"V",,,'seleciona','V','S'})
	Aadd(_aHeader,{" "			 ,"CSTATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Pedido"         ,"C6_NUM" ,"@!"               , 6   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Item"       	,"C6_ITEM" ,"@!"               , TAMSX3("C6_ITEM")[1]   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Cod. Prod."       	,"C6_PRODUTO" ,"@!"               , TAMSX3("C6_PRODUTO")[1]   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Descrição"       	,"C6_DESCRI" ,"@!"               , TAMSX3("C6_DESCRI")[1]   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Qtd. Vend."       	,"C6_QTDVEN" ,PesqPict("SC6","C6_QTDVEN")               , TAMSX3("C6_QTDVEN")[1]   , TAMSX3("C6_QTDVEN")[2],,, "N",, })      	// 3
	aAdd(_aHeader,{"Status"       ,"C6_YSTTSAM" ,"@!"               , 1   , 0,,, "C",,,"R=Rejeitadp;T=Transmitido" })      	// 5
	aAdd(_aHeader,{"Num. Ecosis"       	,"C6_YECONAM" ,"@!"               , TAMSX3("C6_YECONAM")[1]   , 0,,, "C",, })      	// 3

	_aCols	:=	fMontaCols()

	If Len(_aCols) > 0

		DEFINE MSDIALOG oDlg TITLE "Amostras..." FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL STYLE Nor( WS_VISIBLE, WS_POPUP)

		oGetd	:=	MsNewGetDados():New( aPosObj[1][1] + 10, aPosObj[1][2] + 5, aPosObj[1][3] - 5, aPosObj[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlg, _aHeader, _aCols )

		oGetd:oBrowse:bLDblClick := {|| oGetd:EditCell(), oGetd:aCols[oGetd:nAt,1] := iif(oGetd:aCols[oGetd:nAt,1] == 'LBOK','LBNO','LBOK')}

		@ aPosObj[2][1]+08, aPosObj[2][4]-040 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION (cj_Fecha := .F., fh_Esc := .T., oDlg:End()) PIXEL
		@ aPosObj[2][1]+08, aPosObj[2][4]-103 BUTTON oBtInt PROMPT "Integrar Ecosis"   SIZE 060, 012 OF oDlg ACTION Processa({|| fSendEco() }) PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

	Else

		MsgInfo("Não há itens para serem transmitidos!","Aviso")

	EndIf

Return


Static Function ValidPerg()

	local cLoad	    := "BIAFG060" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 :=	SPACE(6)

	aAdd( aPergs ,{1,"Pedido " 	  				,MV_PAR01 ,""  ,"",''  ,'.T.',100,.T.})

	If ParamBox(aPergs ,"Exportação de Amostra para o Ecosis",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet


Static Function fSendEco()

	Local _nPosPed	:=	aScan(oGetd:aHeader,{|x| Alltrim(x[2] == "C6_NUM")})
	Local _nPosIte	:=	aScan(oGetd:aHeader,{|x| Alltrim(x[2] == "C6_ITEM")})
	Local _nI

	BEGIN TRANSACTION
		For _nI	:= 1 to Len(oGetd:aCols)
			If oGetd:aCols[_nI,1] == "LBOK"
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6")+oGetd:aCols[_nI,_nPosPed]+oGetd:aCols[_nI,_nPosIte]))
					Reclock("SC6")
					SC6->C6_YSTTSAM	:=	""
					SC6->(MsUnlock())
				Else
					MsgInfo("Item " + oGetd:aCols[_nI,_nPosIte] + " Não Encontrado!")
					DisarmTransaction()
					Return
				EndIf
			EndIf
		Next 

	END TRANSACTION
	MsgInfo("Itens Marcados para Reenvio ao Ecosis!")

	oDlg:End()

Return

Static Function fMontaCols()

	Local _cAlias	:=	GetNextAlias()

	Local _aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_QTDVEN, SC6.C6_YSTTSAM, SC6.C6_YECONAM
		FROM     %TABLE:SC5% SC5
		JOIN %TABLE:SC6% SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL
		AND SC5.C5_NUM = SC6.C6_NUM
		AND SC6.%NotDel%
		WHERE   SC5.C5_FILIAL =  %XFILIAL:SC5%
		AND SC5.C5_YAPROV <> ''
		AND SC5.C5_YSUBTP IN('A ', 'F ','M ')
		AND SC5.C5_YCONF = 'S'
		AND SC5.%NotDel%
		AND SC6.C6_YECONAM = ''
		AND SC6.C6_YSTTSAM = 'R'
		AND SC6.C6_BLQ <> 'R'
		AND SC5.C5_NUM = %EXP:MV_PAR01%
		AND NOT EXISTS (
		SELECT 1
		FROM %TABLE:SC9% SC9
		WHERE SC9.C9_FILIAL = SC6.C6_FILIAL
		AND SC9.C9_PEDIDO = SC6.C6_NUM
		AND SC9.C9_ITEM = SC6.C6_ITEM
		AND SC9.%NotDel%
		)
		ORDER BY C6_NUM, C6_ITEM
	EndSql

	While (_cAlias)->(!EOF())

		aAdd(_aCols,{'LBNO',"BR_AMARELO",(_cAlias)->C6_NUM,(_cAlias)->C6_ITEM,(_cAlias)->C6_PRODUTO,(_cAlias)->C6_DESCRI,(_cAlias)->C6_QTDVEN,(_cAlias)->C6_YSTTSAM,(_cAlias)->C6_YECONAM,.F.})

		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())

Return _aCols