#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG075
@author Gabriel Rossi Mafioletti
@since 06/11/2018
@version 1.0
@description Análise de Pré-Transferências
@type function
/*/



User Function BIAFG075()

If !Validperg()
	Return
EndIf

Processa({|| fProcessa()})

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG075" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	
	MV_PAR01 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR02 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR03 := Stod("")
	MV_PAR04 := Stod("")
	

	
	aAdd( aPergs ,{1,"Produto De " 	   			,MV_PAR01 ,""  ,"",'SB1'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Produto Até " 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data De " 	   			,MV_PAR03 ,""  ,"",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até " 	   			,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	

	If ParamBox(aPergs ,"Processamento de Pré-Transferências",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		

	EndIf

Return lRet

Static Function fProcessa()

	Local _cAlias	:=	GetNextAlias()
	Local _aCols	:=	{}
	Local _aHeader	:=	{}
	Local _cDataDe	:=	Dtos(MV_PAR03)
	Local _cDataAte	:=	Dtos(MV_PAR04)
	
	Private aSize := MsAdvSize(.F.) //Sem Enchoice

	Private oSyDsSald	:=	Nil
	Private cSyDsSald	:=	SPACE(250)
	Private	oFntTR		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)
	
	Private _lMarcChk	:=	.F.
	Private _lMarcApv	:=	.F.
	

	Private oDlgTR

	aObjects := {}
	// Quantos mais objetos, mais o Method MsObjSize Trabalha para subdividir
	//                 | Fracionamento Horizontal
	//                      | Fracionamento Vertical

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos1                                         |
	+-------------------------------------------------------------------------*/
	AAdd( aObjects, { 100, 400, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos2                                         |
	+-------------------------------------------------------------------------*/
	
	
	BeginSql Alias _cAlias
	
		SELECT SZI.ZI_YDOCORI,SZJ.*
		FROM %TABLE:SZI% SZI
		JOIN %TABLE:SZJ% SZJ ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL
			AND SZI.ZI_DOC = SZJ.ZJ_DOC
			AND SZI.ZI_TIPO = 'TR'
			AND SZJ.ZJ_BAIXA = ''
			AND SZI.%NotDel%
			AND SZJ.%NotDel%
		WHERE ZJ_FILIAL = %XFILIAL:SZJ%
			AND ZJ_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND ZI_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
	
	EndSql

	aadd(_aHeader,{''		  ,'CHECK'     ,'@BMP', 2,0,,	             ,"C",     ,"V",,,'seleciona','V','S'})
	Aadd(_aHeader,{"APV"		         	 ,"APV" ,"@BMP"             , 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	Aadd(_aHeader,{"PROC"		         	 ,"PROCESS" ,"@BMP"             , 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Documento"       ,"DOC" 	,"@!"               , 09   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Produto"       ,"CODPRO" 	,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Descrição"       ,"DESPRO" 	,"@!"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Política"       ,"POLIT" 	,"@!"               , 1   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Local Origem"       ,"LOCORI" 	,"@!"               , 02   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Local Destino"       ,"LOCDEST" 	,"@!"               , 02   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Qtd. Suger."       ,"QTDSUG" 	,"@E 999,999,999"               , 09   , 0,,, "N",, })      	// 1
	aAdd(_aHeader,{"Qtd. Digit."       ,"QTDDIG" 	,"@E 999,999,999"               , 09   , 0,,, "N",, })      	// 1
	aAdd(_aHeader,{"Msg. Erro"       ,"ERRO" 	,"@S30"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Doc. Orig."       ,"DOCORI" 	,"@!"               , 09   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Registro"       ,"REG" 	,"@!"               , 17   , 0,,, "N",, })      	// 1

	
	If (_cAlias)->(!EOF())
	
		While (_cAlias)->(!EOF())
			
			aAdd(_aCols,{;
						"LBNO",;
						"BR_VERDE",;
						"BR_BRANCO",;
						(_cALias)->ZJ_DOC,;
						(_cAlias)->ZJ_COD,;
						(_cAlias)->ZJ_DESCRI,;
						POSICIONE("ZCN",2,xFilial("ZCN")+(_cAlias)->ZJ_COD+(_cAlias)->ZJ_LOCAL,"ZCN_POLIT"),;
						(_cAlias)->ZJ_LOCAL,;
						(_cAlias)->ZJ_YLOCORI,;
						(_cAlias)->ZJ_QUANT,;
						0,;
						SPACE(250),;
						(_cAlias)->ZI_YDOCORI,;
						(_cAlias)->R_E_C_N_O_,;
						.F.})
		
			(_cAlias)->(DbSkip())
		EndDo
	EndIf
	
	DEFINE MSDIALOG oDlgTR TITLE "Pré-Transferências" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
	
	@ aPosObj1[2][1], aPosObj1[2][2] GROUP oGpMRP1 TO aPosObj1[2][3], aPosObj1[2][4] PROMPT "Saldo" OF oDlgTR COLOR 0, 16777215 PIXEL
	@ aPosObj1[2][1]+10, aPosObj1[2][2]+05 SAY oSyDsSald PROMPT cSyDsSald SIZE 446, 011 OF oDlgTR FONT oFntTR COLORS 0, 16777215 PIXEL	
	
	
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpMRP1 TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Pré-Transferências..." OF oDlgTR COLOR 0, 16777215 PIXEL
	
	oGdTrans	:=	MsNewGetDados():New( aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"QTDDIG"},, 999, 'U_BFG75FOK()', "", "AllwaysTrue", oDlgTR, _aHeader, _aCols, { || fChgTr() } )
	
	oGdTrans:oBrowse:blDblClick	:= {|| oGdTrans:EditCell(),fAprov()}
	
	oGdTrans:oBrowse:bHeaderClick	:= {|| fMarcaT()}	
	
	@ aPosObj1[2][1]+08, aPosObj1[2][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar" SIZE 037, 012 OF oDlgTR ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgTR:End()) PIXEL
	
	@ aPosObj1[2][1]+08, aPosObj1[2][4]-103 BUTTON oBt2CockSim PROMPT "Processar"   SIZE 060, 012 OF oDlgTR ACTION Processa({|| fGrava() }) PIXEL
	
	@ aPosObj1[2][1]+08, aPosObj1[2][4]-165 BUTTON oBt3CockSim PROMPT "Conferir"   SIZE 060, 012 OF oDlgTR ACTION Processa({|| fConfere() }) PIXEL
	
	
	ACTIVATE MSDIALOG oDlgTR CENTERED
	
	(_cAlias)->(DbCloseArea())
	
Return



Static Function fAprov()

	Local _aCols	:=	{}
	Local _nPosApv	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "APV"})
	Local _nPosChk	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CHECK"})
	Local _nPosQtd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})

	If oGdTrans:oBrowse:nColpos == _nPosApv
	
		If oGdTrans:aCols[oGdTrans:nAt,_nPosApv] == "BR_VERDE"
	
			oGdTrans:aCols[oGdTrans:nAt,_nPosQtd]	:=	0
			oGdTrans:aCols[oGdTrans:nAt,_nPosApv]	:=	"BR_VERMELHO"
			oGdTrans:aCols[oGdTrans:nAt,_nPosChk] 	:=	"LBOK"
	
		Else
			oGdTrans:aCols[oGdTrans:nAt,_nPosApv]	:=	"BR_VERDE"
		EndIf
	
	EndIf
	
	If oGdTrans:oBrowse:nColpos == _nPosChk
		If oGdTrans:aCols[oGdTrans:nAt,_nPosChk] == "LBOK" 
			oGdTrans:aCols[oGdTrans:nAt,_nPosChk] := "LBNO"
			oGdTrans:aCols[oGdTrans:nAt,_nPosQtd]	:=	0
			oGdTrans:aCols[oGdTrans:nAt,_nPosApv]	:=	"BR_VERDE"
		Else
			oGdTrans:aCols[oGdTrans:nAt,_nPosChk] := "LBOK"
		EndIf
	EndIf
	
	oGdTrans:Refresh()
	

Return

User Function BFG75FOK()

	Local _cField	:=	ReadVar()
	Local _lRet		:=	.T.
	Local _nSaldo
	Local _nI
	Local _nQtdTr	:=	0
	Local _nPosPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CODPRO"})
	Local _nPosLOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCORI"})
	Local _nPosQtdS	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDSUG"})
	Local _nPosQtdD	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})
	Local _nPosChk	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CHECK"})
	Local _nPosDOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DOCORI"})
	Local _nEstMin	

	If Alltrim(_cField) == "M->QTDDIG"
	
		If M->QTDDIG < 0 .And. _lRet
			MSGINFO("Não é possível inserir valor negativo!")
			_lRet	:=	.F.
		EndIf
	
	EndIF

Return _lRet

Static Function fGrava()

	If MsgYesno("As Pré Solicitações marcadas serão processadas. Deseja Continuar?")
		BEGIN TRANSACTION
			fTransf()
		END TRANSACTION
	Else
		Return
	EndIf

Return


Static Function fTransf()

	Local _nI
	Local _nPosChk	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CHECK"})
	Local _nPosApv	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "APV"})
	Local _nPosPrc	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "PROCESS"})
	Local _nPosRec	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "REG"})
	Local _nPosLOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCORI"})
	Local _nPosLDst	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCDEST"})
	Local _nPosPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CODPRO"})
	Local _nPosQtdS	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDSUG"})
	Local _nPosQtdD	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})
	Local _nPosErro	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "ERRO"})
	Local _nPosDoc	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DOC"})
	Local _nPosDOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DOCORI"})
	Local _nPosDsPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DESPRO"})
	
	Local _aCExcel	:=	{}
	Local _aDExcel	:=	{}
	
	Local cSql
	Local _cDocTr	:=	""
	Local _lAtuRes	:=	.F.
	
	Local _nEstMin	:=	0
	Local _nQtdTr	:=	0
	
	_aCExcel := {}
	AADD(_aCExcel,{ "DOCUMENTO"     ,"C",09,0 } )
	AADD(_aCExcel,{ "PRODUTO"    ,"C",15,0 } )
	AADD(_aCExcel,{ "DESCRICAO"      ,"C",30,0 } )
	AADD(_aCExcel,{ "ALMOX. ORIGEM"      ,"C",02,0 } )
	AADD(_aCExcel,{ "ALMOX. DESTINO"      ,"C",02,0 } )
	AADD(_aCExcel,{ "QUANT"      ,"N",18,8 } )
	AADD(_aCExcel,{ "PRE-REQUIS."      ,"C",09,0 } )
	
		
	For _nI	:= 1 to Len(oGdTrans:aCols)
		_lAtuRes	:=	.F.
		If oGdTrans:aCols[_nI,_nPosChk] == "LBOK"

			If oGdTrans:aCols[_nI,_nPosApv] == "BR_VERDE"
				//Verifica Saldo no Armazém Origem
				_nSaldo := fCalcSal(oGdTrans:aCols[_nI,_nPosPrd],oGdTrans:aCols[_nI,_nPosLOri])
				_nEstMin	:=	fCalcEMin(oGdTrans:aCols[_nI,_nPosPrd],oGdTrans:aCols[_nI,_nPosLOri])
				
				_nQtdTr	:=	If(oGdTrans:aCols[_nI,_nPosQtdD] > 0,oGdTrans:aCols[_nI,_nPosQtdD], oGdTrans:aCols[_nI,_nPosQtdS]) 
				
				If _nSaldo - _nEstMin - _nQtdTr >= 0
					_cDocTr	:=	fExecTr(oGdTrans:aCols[_nI,_nPosPrd],oGdTrans:aCols[_nI,_nPosLOri],oGdTrans:aCols[_nI,_nPosLDst],_nQtdTr,_nI)
					If !Empty(_cDoctr)
						oGdTrans:aCols[_nI,_nPosPrc]	:=	"BR_VERDE"
						oGdTrans:aCols[_nI,_nPosErro]	:=	"TRANSF No: " + _cDocTr
						SZJ->(DbGoto(oGdTrans:aCols[_nI,_nPosRec]))
						Reclock("SZJ",.F.)
						SZJ->ZJ_BAIXA	:=	"S"
						SZJ->ZJ_DOCTRAN	:=	_cDocTr
						SZJ->ZJ_QTAPROV	:=	_nQtdTr
						SZJ->(MsUnlock())
						IF oGdTrans:aCols[_nI,_nPosDOri] <> "TRANSAUTO"
							fAltRequi(oGdTrans:aCols[_nI,_nPosDOri]) //Altera Quantidade Aprovada na Requisição principal
							fResSaldo() //Reserva Saldo Para a transferência
						EndIf
						aAdd(_aDExcel,{;
							oGdTrans:aCols[_nI,_nPosDoc],;
							oGdTrans:aCols[_nI,_nPosPrd],;
							oGdTrans:aCols[_nI,_nPosDsPrd],;
							oGdTrans:aCols[_nI,_nPosLOri],;
							oGdTrans:aCols[_nI,_nPosLDst],;
							_nQtdTr,;
							oGdTrans:aCols[_nI,_nPosDOri];							
							})
					Else
						oGdTrans:aCols[_nI,_nPosPrc]	:=	"BR_VERMELHO"
						oGdTrans:aCols[_nI,_nPosPrc]	:=	"BR_VERDE"
					EndIf
				Else
					oGdTrans:aCols[_nI,_nPosPrc]	:=	"BR_VERMELHO"
					oGdTrans:aCols[_nI,_nPosErro]	:=	"SALDO INSUFICIENTE NO ARMAZÉM ORIGEM"
				EndIf
				
			Else
				SZJ->(DbGoto(oGdTrans:aCols[_nI,_nPosRec]))
				Reclock("SZJ",.F.)
				SZJ->ZJ_BAIXA	:=	"R"
				SZJ->(MsUnlock())
			EndIf
			fCheckSZI(oGdTrans:aCols[_nI,_nPosDoc])
 
		
		EndIF

	Next

	MsgInfo("Processameto Finalizado!")

	If Len(_aDExcel) > 0
		U_BIAxExcel(_aDExcel, _aCExcel, "BIAFG075"+strzero(seconds()%3500,5) )
	EndIf

	oBt2CockSim:Hide()

Return

Static Function fCalcEMin(_cCod,_cLocal)

	Local _nRet	:=	0
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	
	
	BeginSql Alias _cAlias
	
		SELECT ISNULL(ZCN_ESTSEG,0) ESTSEG
			FROM %TABLE:ZCN%
			WHERE ZCN_FILIAL = %xFilial:ZCN%
				AND ZCN_COD = %Exp:_cCod%
				AND ZCN_LOCAL = %Exp:_cLocal%
				AND %NotDel%
	
	EndSql
	
	_nRet	:=	(_cAlias)->ESTSEG
	
	(_cAlias)->(DbCloseArea())
	
	RestArea(_aArea)
	
Return _nRet


Static Function fExecTr(_cCod,_cLocori,_cLocDest,_nQuant,_nI)

	Local _aTransf	:=	{}
	Local _cDoc	:=	 UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) )

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(_cCod))

	aadd ( _aTransf, {_cDoc, dDataBase } )
	
	aadd ( _aTransf,	{ _cCod                                     ,;
			Substr(SB1->B1_DESC,1,30)                                ,;
			SB1->B1_UM										                   ,;
			_cLocori                                                          ,;
			""                                                                ,;
			_cCod                                                   ,;
			Substr(SB1->B1_DESC,1,30)                              ,;
			Substr(SB1->B1_DESC,1,30)                               ,;
			_cLocDest                                                          ,;
			""                                                                ,;
			"                    "                                            ,;
			""                                                                ,;
			"      "                                                          ,;
			ctod("  /  /  ")                                                  ,;
			0.00                                                              ,;
			_nQuant                                                     ,;
			ConvUM(_cCod, _nQuant, 0, 2)                          ,;
			CriaVar("D3_ESTORNO")                                             ,;
			CriaVar("D3_NUMSEQ")                                              ,;
			""                                                                ,;
			ctod("  /  /  ")                                                  ,;
			CriaVar("D3_ITEMGRD")                                             ,;
			CriaVar("D3_OBSERVA")                                             })

			lMsErroAuto := .f.
			MSExecAuto({|x,y| mata261(x,y)},_aTransf,3)

			If lMsErroAuto
				Mostraerro()
				_cDoc	:=	""
			EndIf

Return _cDoc

Static Function fCalcSal(_cCod,_cLocal)
	
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local _nret	:=	0
	
	BeginSql Alias _cAlias
	
		SELECT ISNULL(B2_QATU - B2_RESERVA,0) SALDO
			FROM %TABLE:SB2%
			WHERE B2_FILIAL = %xFILIAL:SB2%
				AND B2_COD = %Exp:_cCod%
				AND B2_LOCAL = %Exp:_cLocal%
				AND %NotDel%
	EndSql
	
	_nret	:=	(_cAlias)->SALDO

	(_cAlias)->(DbCloseArea())
	
	RestArea(_aArea)

Return _nRet

Static Function fCalcTrans(_cCod,_cLocal)

	
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	
	Local _nQtd	:=	0
	
	BeginSql Alias _cAlias
	
		SELECT ISNULL(SUM(ZJ_QUANT),0) QUANT
		FROM %TABLE:SZI% SZI
		JOIN %TABLE:SZJ% SZJ ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL
		 	AND SZI.ZI_FILIAL = %XFILIAL:SZI%
			AND SZI.ZI_DOC = SZJ.ZJ_DOC
			AND SZI.%NotDel%
			AND SZJ.%NotDel%
			AND SZI.ZI_TIPO = 'TR'
			AND SZJ.ZJ_BAIXA = ''
			AND SZJ.ZJ_LOCAL = %Exp:_cLocal%
			AND SZJ.ZJ_COD = %Exp:_cCod%
	
	EndSql

	_nQtd	:=	(_cAlias)->QUANT

	(_cAlias)->(DbCloseArea())
	
	RestArea(_aArea)

Return _nQtd

Static Function fCheckSZI(_cDoc)

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	
	
	BeginSql Alias _cAlias
	
		SELECT TOP 1 ISNULL(SZI.R_E_C_N_O_,0) REG
			FROM %TABLE:SZI% SZI
			WHERE SZI.ZI_FILIAL = %XFILIAL:SZI%
				AND SZI.ZI_DOC = %Exp:_cDoc%
				AND NOT EXISTS(	SELECT 1 
								FROM %TABLE:SZJ% SZJ
								WHERE SZJ.ZJ_FILIAL = SZI.ZI_FILIAL
									AND SZJ.ZJ_DOC = SZI.ZI_DOC
									AND SZJ.ZJ_BAIXA = ''
									AND SZJ.%NotDel%
								)
				AND SZI.ZI_TIPO = 'TR'
				AND SZI.%NotDel%
				
		EndSql
		
		If (_cAlias)->REG > 0
			SZI->(DbGoTo((_cAlias)->REG))
			IF SZI->(!EOF())
				Reclock("SZI",.F.)
				SZI->ZI_BAIXA	:=	"S"
				SZI->(MsUnlock())
			EndIf
		Endif
		
		(_cAlias)->(DbCloseArea())

		RestArea(_aArea)
Return

Static Function fChgTr()

	Local _nPosPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CODPRO"})
	Local _nPosLOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCORI"})
	Local _nPosLDes:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCDEST"})
	Local _nPosQtdS	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDSUG"})
	Local _nPosQtdD	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})
	Local _nPosChk	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CHECK"})
	
	Local _nAt	:=	oGdTrans:nAt
	Local _nI
	Local _nQtdTr	:=	0
	
	Local _nSaldo
	Local _nSalDest
	
	Local _nEstMin
	
		
	_nSaldo	:=	fCalcSal(oGdTrans:aCols[_nAt,_nPosPrd],oGdTrans:aCols[_nAt,_nPosLOri])
		
	_nSalDest	:=	fCalcSal(oGdTrans:aCols[_nAt,_nPosPrd],oGdTrans:aCols[_nAt,_nPosLDes])

	_nEstMin	:=	fCalcEMin(oGdTrans:aCols[_nAt,_nPosPrd],oGdTrans:aCols[_nAt,_nPosLOri])	
		
	cSyDsSald	:=	"ARMAZÉM ORIGEM: " + oGdTrans:aCols[oGdTrans:nAt,_nPosLOri] +" - SALDO: "+ Alltrim(Str(_nSaldo - _nEstMin)) + " / ARMAZÉM DEST.: " + oGdTrans:aCols[oGdTrans:nAt,_nPosLDes] + " - SALDO: " + Alltrim(Str(_nSalDest))
	
	oSyDsSald:Refresh()

Return

Static Function fMarcaT()

	Local _nI
	Local _nPosChk	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CHECK"})
	Local _nPosApv	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "APV"})


	If oGdTrans:oBrowse:nColpos == _nPosChk
		_lMarcChk	:=	!_lMarcChk
		
		For _nI	:=	1 To Len(oGdTrans:aCols)
		
			oGdTrans:aCols[_nI,_nPosChk]	:=	IIF(_lMarcChk,"LBOK","LBNO")
	
		Next
	
	EndIF

	If oGdTrans:oBrowse:nColpos == _nPosApv
		_lMarcApv	:=	!_lMarcApv
		
		For _nI	:=	1 To Len(oGdTrans:aCols)
		
			oGdTrans:aCols[_nI,_nPosApv]	:=	IIF(_lMarcApv,"BR_VERDE","BR_VERMELHO")
			oGdTrans:aCols[_nI,_nPosChk]	:=	"LBOK"
		Next
	
	EndIF

	oGdTrans:Refresh()

Return


Static Function fResSaldo()

	Local _cQry	:=	""
	Local _nQtd	:=	MIN(SZJ->ZJ_QTAPROV,SZJ->ZJ_QUANT)
	
	_cQry	:=	"UPDATE " + RETSQLNAME("SB2") + " SET B2_RESERVA = B2_RESERVA + " + ValtoSql(_nQtd) + " WHERE B2_FILIAL = " + ValtoSql(xFilial("SB2")) + " AND B2_COD = " +; 
				ValToSql(SZJ->ZJ_COD) + " AND B2_LOCAL = " + ValtoSql(SZJ->ZJ_YLOCORI) + " AND D_E_L_E_T_ = ''"

	TcSqlExec(_cQry)

Return


Static Function fAltRequi(_cDocOri)

	Local _cQry	:=	""
	
	_cQry	:=	" UPDATE SZJ " + ;
				" SET SZJ.ZJ_QTAPROV = CASE WHEN SZJ.ZJ_QUANT - SZJ.ZJ_QTAPROV > " + ValtoSql(SZJ->ZJ_QTAPROV) +; 
				" 								THEN " + ValtoSql(SZJ->ZJ_QTAPROV) +; 
				" 								ELSE SZJ.ZJ_QUANT - SZJ.ZJ_QTAPROV END " +;
				" FROM " + RetSqlName("SZI") + " SZI " + ;
				" JOIN " + RetSqlName("SZJ") + " SZJ " + ;
				" ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL " + ;
				"	AND SZI.ZI_DOC = SZJ.ZJ_DOC " + ;
				" WHERE SZI.ZI_DOC = " + ValtoSql(_cDocOri) + " " +;
				"	AND SZJ.ZJ_COD = " + ValtoSql(SZJ->ZJ_COD) + " " +;
				"	AND SZJ.D_E_L_E_T_ = ''	" + ;
				"	AND SZI.D_E_L_E_T_ = '' " 
				
	TcSqlExec(_cQry)

Return

Static Function fConfere()

	Local _aCExcel	:=	{}
	Local _aDExcel	:=	{}
	Local _nI
	Local _nPosPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "CODPRO"})
	Local _nPosQtdS	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "QTDSUG"})
	Local _nPosDsPrd	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DESPRO"})
	Local _nPosLOri	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCORI"})
	Local _nPosLDst	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "LOCDEST"})
	Local _nPosDoc	:=	aScan(oGdTrans:aHeader,{|x| Alltrim(x[2]) == "DOC"})

	
	Local _nPos
	
	AADD(_aCExcel,{ "DOCUMENTO"     ,"C",09,0 } )
	AADD(_aCExcel,{ "PRODUTO"    ,"C",15,0 } )
	AADD(_aCExcel,{ "DESCRICAO"      ,"C",30,0 } )
	AADD(_aCExcel,{ "ALMOX. ORIGEM"      ,"C",02,0 } )
	AADD(_aCExcel,{ "ALMOX. DESTINO"      ,"C",02,0 } )
	AADD(_aCExcel,{ "QUANT"      ,"N",18,8 } )
	AADD(_aCExcel,{ "ESTMIN"      ,"N",18,8 } )
	
	For _nI	:= 1 to Len(oGdTrans:aCols)
	
		aAdd(_aDExcel,{;
							oGdTrans:aCols[_nI,_nPosDoc],;
							oGdTrans:aCols[_nI,_nPosPrd],;
							oGdTrans:aCols[_nI,_nPosDsPrd],;
							oGdTrans:aCols[_nI,_nPosLOri],;
							oGdTrans:aCols[_nI,_nPosLDst],;
							oGdTrans:aCols[_nI,_nPosQtdS],;
							fCalcEMin(oGdTrans:aCols[_nI,_nPosPrd],oGdTrans:aCols[_nI,_nPosLOri]);							
							})

	Next _nI
	
	If Len(_aDExcel) > 0
	
		U_BIAxExcel(_aDExcel, _aCExcel, "BIAFG075"+strzero(seconds()%3500,5) )
		
	EndIf
		
Return