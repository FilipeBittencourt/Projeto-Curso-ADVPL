#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0010
@author Gabriel Rossi Mafioletti
@since 03/09/2019
@version 1.0
@description Faturamento de Nota Fiscal
@type function
/*/

User Function BACP0010(_cCarga,_cEmp)

	Local _oProcess
	Local oObj := Nil
	Local lPrintOk := .F.

	Default _cEmp		:=	""

	Public _XCRGATFAT 	:= .T.

	Public cEmpCarga	:= _cEmp
	Public cQNumCarga	:= _cCarga
	Public xBiaVTotNf 	:= 0

	Private oFat
	Private cCarga 		:= _cCarga
	Private cEmp		:=	_cEmp	

	MV_PAR11	:=	2

	//SetPrint para marcar Carga como start por Faturamento Automatico
	If ( AllTrim(CEMPANT) <> "07" )
		oObj := TFaturamentoMonitor():New()	
		lPrintOk := oObj:SetPrintOk(_cCarga, "A")
	Else 
		lPrintOk := .T.
	EndIf

	If lPrintOk

		If IsBlind()

			fProcess(Nil,_cCarga)

		Else
			_oProcess := MsNewProcess():New ( {|| fProcess(@_oProcess,_cCarga) }, "Faturamento Automático", "Aguarde Enquanto a Carga é Faturada", .F. )
			_oProcess:Activate()
		EndIf

	EndIf

	oObj := Nil

Return

Static Function fProcess(_oProcess,_cCarga)

	Local oPedido
	Local _nPeds
	Local aPerg := {}
	Local _nI, nCount

	oFat	:=	TFaturamentoAutomatico():New()

	oFat:GetPedidosFaturar(_cCarga,cEmp)

	_nPeds	:=	oFat:oPedidos:GetCount()

	If !IsBlind()

		_oProcess:SetRegua1(_nPeds)

		_oProcess:SetRegua2(_nPeds)

	EndIf

	For _nI	:=	1 to _nPeds

		oPedido	:=	oFat:oPedidos:GetItem(_nI)

		If Len(oPedido:aItensFaturar) == 0
			ConOut('BACP0010::Não há pedidos ou algum pedido da carga não está liberado !' +cEmp+'/'+cFilAnt+' - '+ Time())
			Return
		EndIf	
	Next


	For nCount := 1 To _nPeds


		If !IsBlind()
			_oProcess:IncRegua1("Faturando Pedidos - " + Alltrim(Str(nCount)) + "/" + Alltrim(Str(_nPeds)) )
		EndIf
		oPedido	:=	oFat:oPedidos:GetItem(nCount)

		If !IsBlind()
			_oProcess:IncRegua2("Faturando Pedido  - " + oPedido:cNumPed )
		EndIF

		If !Empty(oPedido:cSerie)

			Public nTransp   := oPedido:cTransport
			Public nTpFrete  := oPedido:nTipoFrete
			Public nFlagFT   := "S"
			Public xVlFrtInf := 0
			Public nNovaCond := Nil

			xBiaVTotNf := 0  //Problem Imposto - Zerar essa variavel a cada NF - é usado no PE M460SOLI - Fernando em 22/01/2020

			Pergunte("MT460A", .F.,,,,, @aPerg)		
			MV_PAR01 := 2
			MV_PAR02 := 1
			MV_PAR03 := 1
			MV_PAR17 := 1
			MV_PAR18 := 1
			MV_PAR19 := 2
			MV_PAR20 := 2	
			
			//Ticket 22024 - adicionado em 07/02/2020 - geracao de Guias para DIFAL e FECP
			MV_PAR24 := 1	
			MV_PAR25 := 1	

			__SaveParam("MT460A", aPerg)

			//Function MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
			oPedido:cNota := MaPvlNfs(oPedido:aItensFaturar,oPedido:cSerie,.F.,.T.,.T.,.T.,.T.,3,2,.F.,.F.,,,,,,Stod(""))

		EndIf

	Next

Return
