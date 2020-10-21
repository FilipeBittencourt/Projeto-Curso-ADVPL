#Include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT120OK   บAutor  ณMicrosiga           บ Data ณ  09/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo final pedido de compra                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT120OK()

	Local lRet     := .T.

	If !IsBlind()

		IIF(Findfunction('u_monPrcPer'), StartJob('U_monPrcPer', GetEnvServer(), .F., 'MT120OK.prw', ''), '') //INCLUSAO AUTOMATICA POR TOTVSIP FORTMONPROC --GUSTAVO LUIZ

		If INCLUI      
			
			//Chamado #27968 - Kuhn
			If DA120Emis != dDataBase
				MsgAlert('A data de emissใo terแ que ser igual a data do dia corrente')
				lRet := .F.
			Endif
			
		EndIf
	
		If INCLUI .OR. ALTERA
			If cTpFrete == 'F' .AND. Type('cA120YTran') <> 'U' .AND. AllTrim(cA120YTran) == ''
				Msginfo('Favor informar a transportadora')
				lRet := .F.
			EndIf
		EndIf 

		If (INCLUI .Or. ALTERA) .And. !U_VIX259CD()
			
			Return(	.F.)
							
		EndIf
		
		//Se for c๓pia de pedido de venda
		//deve atualizar o campo de quantidade liberada para zero (0)
		If SC7->(FieldPos("C7_YQTDLIB")) > 0
		
			If (!INCLUI .AND. !ALTERA)
				QTDLIBZERO()
			EndIf
			
			lRet := MT120EST(aHeader, aCols, CA120NUM, lRet, CA120FORN, CA120LOJ)
			
			If ! lRet
			
				//If !GetNewPar("MV_YFVLDXM", .T.)
				
					// Tratar para que o pedido seja incluido bloqueado
					// Nao precisa de tratamento pois os pedidos ja nascem bloqueados
					
					lRet := .T.
				
				//EndIf
			
			EndIf

		EndIf

	EndIf
	
Return lRet

/*retDaFuncStatic := StaticCall( xParam1, xParam2, xParam3, ..., ..., xParamN)

xParam1 := NomeDoPrograma (sem aspas), onde se encontra a Static Function
xParam2 := NomeDaStaticFunction (sem aspas), a ser executada
xParam3 := A partir desse espa็o sใo definidos os parametros que sใo passados
para a Static Function que esta sendo invocada.*/

/*/{Protheus.doc} MT120EST
@description	Fun็ใo para analisar estoque e media consumo, com objetivo de 
				travar o usuแrio na conclusใo do pedido de compra.
				<br> Atendendo ao chamado: 81492
@author 		Henry de Almeida Woelffel <br> Email: henry.almeida@brasoftsistemas.com.br  <br> Tel.: (27) 9.9823-7597
@see 			http://www.brasoftsistemas.com.br
@since 			01/02/2016
@obs			Chamados internos envolvidos:
				<br> Chamado: 81492 de 11/01/2016 - Solicitante: Leonardo
@source 		MT120OK.PRW
@version		1.0
/*/
Static Function MT120EST(aHeader, aCols, CA120NUM, _lRet, CA120FORN, CA120LOJ)

	Local _aArea	:= GetArea()
	Local _lRet 	:= _lRet //Variavel para nใo permitir seguir com o processo

	//Verifica posicao dos campos no aheader
	Local _nPosHI 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_ITEM"})
	Local _nPosHP 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_PRODUTO"})
	Local _nPosHD 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_DESCRI"})
	Local _nPosHL 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_LOCAL"})
	Local _nPosHQ 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_QUANT"})
	Local _nPosHMP 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_YMEDPON"})
	Local _nPosHLB 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_YQTDLIB"})
	Local _nPosHOB 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_OBS"})
	Local _nPosTpCmp 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_YTIPCMP"})

	Local _cProduto	:= ""   
	Local _cLocal		:= ""
	Local _cItem		:= ""
	Local _cPedido	:= ""
	Local _cDescri	:= ""
	Local _cCodCru	:= ""
	Local _cObs		:= ""
	Local _nQtdReq	:= 0
	local _nQtdLib	:= 0
	Local _nQtdAtu	:= 0
	Local _cTipoCmp	:= ''
	
	Local _aMens		:= {}

	Local _nEstAtu	:= 0	//Estoque atual para o produto posicionado
	Local _nEstTot	:= 0	//Estoque total para o produto posicionado
	Local _nQtdPend	:= 0	//Quantidade pendente para atendimento
	Local _nDiasEst	:= 0	//Dias Estoque
	Local _nMedPon	:= 0	//M้dia Ponderada
	
	Local _nLimDias	:= GetNewPar("MV_YLIMDIA",120)
	Local _nSldPed	:= 0	//Saldo de pedidos
	Local _nX			:= 0
	
	Private aColsEx := {}

	//Processar cada item do pedido de compras.
	For _nX := 1 to Len(acols)
	
		_nQtdReq	:= acols[_nX,_nPosHQ]
		_nQtdLib	:= acols[_nX,_nPosHLB]
	
		//Se linha acols deletada (Ihorran) nao considera e quantidade requisita maior que jแ liberada (henry)
		If !aCols[_nX][Len(aCols[_nX])] .and. (_nQtdReq > _nQtdLib) 

			_cPedido	:= CA120NUM //Variavel padrใo tela protheus
			_cItem		:= acols[_nX,_nPosHI]
			_cProduto	:= acols[_nX,_nPosHP]
			_cLocal	:= acols[_nX,_nPosHL]
			_cDescri	:= acols[_nX,_nPosHD]
			_cObs		:= acols[_nX,_nPosHOB]
			
			If _nPosTpCmp > 0
				_cTipoCmp	:= acols[_nX,_nPosTpCmp]
			EndIf
						
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+_cProduto))
			
			_nMedPon 	:= MedPondG(_cProduto)
			_nEstAtu	:= EstAtuCruG(_cProduto)	//StaticCall(VIXA113, EstAtual, _cProduto)
			_nSldPed	:= SaldoPed(_cPedido, _cProduto, _cLocal, _cItem) //StaticCall(MS170QTD, GetSalPed, _cProduto, _cLocal)
			_nDiasEst	:= round( ( (_nEstAtu + _nQtdReq + _nSldPed)  /_nMedPon) * 30, 0) //( (_nEstAtu + _nQtdPend + _nQtdReq + _SldPed)  /_nMedPon) * 30	
			
			//Dias em estoque maior que 120 dias bloqueia
			//Toda compra por oportunidade deverแ ser analisada pelo gerente de compras independente da quandidade de dias
			If _nDiasEst > _nLimDias .Or. _cTipoCmp == 'CO'// CO = Compra por oportunidade //.and. (_nQtdReq > _nQtdLib)
		        Aadd(aColsEx, {	_cPedido	,;	//[01] Pedido
	        					_cItem		,;	//[02] Item Pedido
	        					_cProduto	,;	//[03] Codigo Produto
	        					_cDescri	,;	//[04] Descricao Produto
	        					_cLocal	,;	//[05] Local / Armazem
	        					_nDiasEst	,;	//[06] Dias de Estoque
	        					_nQtdReq	,;	//[07] Quantidade Requerida
	        					_nEstAtu	,;	//[08] Estoque Atual
	        					_nMedPon	,;	//[09] Media Ponderada
	        					_nEstTot 	,;	//[10] Estoque Total
	        					_nSldPed 	,;	//[11] Quantidade Pendente //era _nQtdPend
	        					_nX			,;	//[12] Posicao no acols 
	        					_cObs		,; 	//[13]	Observacao do item
	        					.F.	}) 	
	        EndIf 

		EndIf
		
	Next _nX

	//Se existir um produto que caiu na regra, nใo permite alterar pedido e liberar.
	If !IsBlind()
		If Len(aColsEx) > 0
			_lRet := MT120MENS()
		EndIf 
	EndIf

	RestArea(_aArea)

return (_lRet)


/*/{Protheus.doc} MT120MENS
@description	Fun็ใo para exibir mensagem para usuแrio com os produtos
				que estใo bloqueados.
				<br> Atendendo ao chamado: 81492
@author 		Henry de Almeida Woelffel <br> Email: henry.almeida@brasoftsistemas.com.br  <br> Tel.: (27) 9.9823-7597
@see 			http://www.brasoftsistemas.com.br
@since 			01/02/2016
@obs			Chamados internos envolvidos:
				<br> Chamado: 81492 de 11/01/2016 - Solicitante: Leonardo
@source 		MT120OK.PRW
@version		1.0
/*/
Static Function MT120MENS()

Local _aRet := {}
Local _lRet := .F. 

Local oData
Local oGData
Local dGData := Date()  

Local oGUser
Local cGUser := Replicate(" ",25)
Local oUsuario

Local oGSenha
Local cGSenha := Replicate(" ",30)
Local oSEvent

//Static oDlgEvent
Static oButton1
Static oButton2

Private oGTxtPsq
Private cGTxtPsq 	:= Replicate(" ",30)

Private oDlgEvent
Private oMSNew
 
/*inicio novo campo obs*/
Private	oSObsTxt
Private	oGObsTxt
Private	cGObsTxt := Replicate(" ",30)
/*Fim novo campo obs*/

If len(aColsEx) = 0
	MsgAlert("Nใo existe produtos bloqueados no pedido.")
	Return(.f.)
EndIf

  DEFINE MSDIALOG oDlgEvent TITLE "Itens Bloqueados" FROM 000, 000  TO 300, 795 COLORS 0, 16777215 PIXEL
    
    fMSNewGet1()                                                                       

	@ 014, 007 MSGET oGData VAR dGData SIZE 042, 010 OF oDlgEvent COLORS 0, 16777215 PIXEL
	@ 005, 007 SAY oData PROMPT "Data" SIZE 050, 007 OF oDlgEvent COLORS 0, 16777215 PIXEL

    @ 014, 058 MSGET oGUser VAR cGUser SIZE 050, 010 OF oDlgEvent COLORS 0, 16777215 PIXEL
    @ 005, 058 SAY oUsuario PROMPT "Usuแrio" SIZE 030, 007 OF oDlgEvent COLORS 0, 16777215 PIXEL	
    
    @ 014, 118 MSGET oGSenha VAR cGSenha SIZE 050, 010 PASSWORD OF oDlgEvent COLORS 0, 16777215 PIXEL
    @ 005, 118 SAY oSEvent PROMPT "Senha" SIZE 030, 007 OF oDlgEvent COLORS 0, 16777215 PIXEL
        
    //exibir a observacao
    @ 115, 007 SAY oSObsTxt PROMPT "Observa็๕es Complementares" SIZE 078, 007 OF oDlgEvent COLORS 0, 16777215 PIXEL    
    //@ 125, 007 GET oGObsTxt VAR cGObsTxt SIZE 388, 020 OF oDlgEvent MULTILINE COLORS 0, 16777215 HSCROLL PIXEL
    @ 125, 007 MSGET oGObsTxt VAR cGObsTxt SIZE 388, 020 VALID FBCHANGE2() OF oDlgEvent COLORS 0, 16777215 PIXEL
    
    @ 014, 293 BUTTON oButton2 PROMPT "Liberar" 	Size 037,12 OF oDlgEvent PIXEL 
    @ 014, 340 BUTTON oButton1 PROMPT "SAIR" 		Size 037,12 OF oDlgEvent PIXEL ACTION oDlgEvent:End()     
    
    oButton2:baction := {|| _aRet := MTVLDUSER(cGuser, cGSenha), ;
    						iIf(_aRet[1], _lRet := MT120USRAP(_aRet[2]),.F. ),;
    						iIf(_aRet[1], AtuAcols(),.F. ),;
    						iIf(_lRet, oDlgEvent:End(), .f. )}  
    						
    //oGObsTxt:BCHANGE := {|| FBCHANGE2()}	
    

  ACTIVATE MSDIALOG oDlgEvent CENTERED

Return (_lRet)

//--------------------------------------------------------------//
// Funcao para montar getdados com produtos com saldo superior. //
//--------------------------------------------------------------//
Static Function fMSNewGet1()

Local nX
Local aHeaderEx := {}
//Local aFieldFill := {}
//Local aFields := {}
Local aAlterFields := {"OBSERV"}

	Aadd(aHeaderEX,{"Pedido"				,"C7_NUM"		,"@!"	,  006,	0,"",,"C","",""})   
	Aadd(aHeaderEX,{"Item"				,"C7_ITEM"		,"@!"	,  004,	0,"",,"C","",""})   
	Aadd(aHeaderEX,{"Produto"			,"C7_PRODUTO"	,"@!"	,  015,	0,"",,"C","",""})   
	Aadd(aHeaderEX,{"Desc. Produto"		,"C7_DESCRI"	,"@!"	,  030,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Local"				,"C7_LOCAL"	,"@!"	,  002,	0,"",,"C","",""})
	Aadd(aHeaderEX,{"Dias Est."			,"DIASEST"		,"@E 999999999.99"	,  012,	2,"",,"N","",""})	
	Aadd(aHeaderEX,{"Qtd. Req."			,"C7_QUANT"	,"@E 999999999.99"	,  012,	2,"",,"N","",""})
	Aadd(aHeaderEX,{"Qtd. Saldo"		,"SALDO"		,"@E 999999999.99"	,  012,	2,"",,"N","",""})
	Aadd(aHeaderEX,{"Med. Pond."		,"MEDPON"		,"@E 999999999.99"	,  012,	2,"",,"N","",""})
	Aadd(aHeaderEX,{"Est. Tot."			,"ESTTOT"		,"@E 999999999.99"	,  012,	2,"",,"N","",""})
	Aadd(aHeaderEX,{"Qtd. Pend."		,"QTDPEND"		,"@E 999999999.99"	,  012,	2,"",,"N","",""})	
	Aadd(aHeaderEX,{"Pos"				,"POSACOLS"	,"@E 999"				,  003,	0,"",,"N","",""})
	Aadd(aHeaderEX,{"Observacao"		,"OBSERV"		,"@!"	,  030,	0,"",,"C","",""})
 
 	oMSNew := MsNewGetDados():New( 032, 007, 110, 393, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgEvent, aHeaderEx, aColsEx)
  
	//oMSNew:OBROWSE:LHSCROLL := .F.  
	oMSNew:bChange := {|| FBCHANGE()}

Return                                      

//--------------------------------------------//
// Funcao para atualizar campo de observacao. //
//--------------------------------------------//
Static Function FBCHANGE2()

local nLinha := oMSNew:nat

oMSnEW:aCols[nLinha][13] := cGObsTxt
oMSnEW:Refresh()
//oGObsTxt:Refresh()


Return .T.


//--------------------------------------------//
// Funcao para atualizar campo de observacao. //
//--------------------------------------------//
Static Function FBCHANGE()

local nLinha := oMSNew:nat

cGObsTxt := oMSnEW:aCols[nLinha][13] //"novo nome e refresh de tela" + cValtochar(nLinha)
oGObsTxt:Refresh()

Return

//--------------------------------------------//
// Funcao para validar usแrio e senha.        //
//--------------------------------------------//
Static Function MTVLDUSER(_cUsuario, _cSenha)

Local _lRet := .f.
Local _cCodUser := PSWRET(1)[1][1]

_cUsuario := Alltrim(_cUsuario)
_cSenha := Alltrim(_cSenha)

PswOrder(2) 
If  PswSeek(_cUsuario) 
     
     If !PswName(_cSenha) 
          MsgAlert("Senha Invแlida, favor digitar novamente!",'Senha' ) 
          _lRet := .F. 
     Else 
         _cCodUser := PSWRET(1)[1][1]
         _lRet := .T. 
     EndIf      
Else 
     MsgAlert('Usuแrio Invแlido, favor digitar novamente!','Usuแrio') 
     _lRet := .F. 
EndIf 

Return ({_lRet,_cCodUser})

//--------------------------------------------------------------//
//Verifica usuแrio aprovador para permitir libera็ใo do pedido. //
//--------------------------------------------------------------//
Static Function MT120USRAP(_cCodUser)

Local _lRetAp 	:= .F.
Local _cUserAprv	:= (GetNewPar('MV_YAPROV','001656_000606'))

_cCodUser := Alltrim(_cCodUser) 

If _cCodUser $ _cUserAprv
	_lRetAp := .T.
Else
	MsgAlert('Usuแrio informado nใo tem permissใo para aprovar pedidos!')
EndIf

Return(_lRetAp)

//--------------------------------------------------------------//
// Saldo do pedido, desconsiderando pedido atual.				 //
//--------------------------------------------------------------//
Static Function SaldoPed(_cPedido, _cProduto, _cLocal, _cItem)

Local _aArea := GetArea()
Local _nSaldo := 0
Local _nQtdAnt := 0

//Verifica posicao dos campos no aheader
Local _nPosHI 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_ITEM"})
Local _nPosHP 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_PRODUTO"})
Local _nPosHL 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_LOCAL"})
Local _nPosHQ 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_QUANT"}) 
Local aSaldo 		:= {}

Default _cPedido := CA120NUM
Default _cProduto := acols[n,_nPosHP]//SC7->C7_PRODUTO

If AllTrim(_cProduto) == ''
	Return 0
Endif

Default _clocal := acols[n,_nPosHL] //SC7->C7_LOCAL
Default _cItem := acols[n,_nPosHI] //SC7->C7_ITEM

	If (!INCLUI .AND. !ALTERA)
		_nQtdAnt := SC7->C7_QUANT
	Else
		_nQtdAnt	:= Posicione("SC7",1,xFilial("SC7")+ _cPedido + _cItem,"C7_QUANT")
	EndIf
	
	aSaldo := StaticCall(VIXA141, EstPendente, _cProduto, IIF(inclui, '', SC7->C7_NUM))
	//_nSaldo 	:= StaticCall(MS170QTD, GetSalPed, _cProduto, _cLocal) - _nQtdAnt 
	_nSaldo 	:= 0
	If Len(aSaldo) > 0 .and. Len(aSaldo)>= 1 .and. Len(aSaldo[1]) >= 2 
		_nSaldo := aSaldo[1, 2]
	EndIf
	 
	//_nSaldo 	+= MTSB2(_cProduto)

RestArea(_aArea)

Return (_nSaldo)


//--------------------------------------------------------------//
// Modifica acols principal antes do salvamento.					 //
//--------------------------------------------------------------//
Static Function AtuAcols()

Local _nPosHO 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_YQTDLIB"})
Local _nPosHOB 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_OBS"})
Local _nX			:= 0

For _nX := 1 to len(oMSnEW:aCols)

	acols[oMSnEW:aCols[_nx,12],_nPosHo] := oMSnEW:aCols[_nx,07]
	acols[oMSnEW:aCols[_nx,12],_nPosHOB] := oMSnEW:aCols[_nx,13]	

next _nX

Return


//--------------------------------------------------------------//
// Utilizado para inicicializado padrใo C7_YDIAEST				 //
// lGat = Para gatilho recebe .T. / Inicializador padrao .F.    //
//--------------------------------------------------------------//
User Function MT120DIA(_lGat)

Local _nDiasEst := 0
Local _nMedPon := 0
//Local _nQtdReq := SC7->C7_QUANT
Local _nEstAtu	:= 0	//Estoque atual para o produto posicionado
Local _nQtdPend	:= 0	//Quantidade pendente para atendimento
Local _nDiasEst	:= 0	//Dias Estoque
Local _SldPed1 := 0

//Verifica posicao dos campos no aheader
Local _nPosHI 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_ITEM"})
Local _nPosHP 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_PRODUTO"})
Local _nPosHL 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_LOCAL"})
Local _nPosHQ 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_QUANT"}) 
Local _cPedido 	:= CA120NUM //SC7->C7_NUM
Local _cProduto 	:= ''
Local _cLocal 	:= ''
Local _cItem 		:= ''
Local _nQtdReq 	:= 0

Default _lGat 	:= .F.

If Len(acols[n]) > _nPosHP
	_cProduto 	:= acols[n,_nPosHP] //SC7->C7_PRODUTO
EndIf

If Empty(_cProduto)
	Return (0)
Endif

_cLocal 	:= acols[n,_nPosHL] //SC7->C7_LOCAL
_cItem 	:= acols[n,_nPosHI] //SC7->C7_ITEM
_nQtdReq 	:= acols[n,_nPosHQ] //SC7->C7_QUANT

If _lGat
	_cPedido 	:= CA120NUM 
	_cProduto 	:= acols[n,_nPosHP] 
	_cLocal 	:= acols[n,_nPosHL]
	_cItem 	:= acols[n,_nPosHI] 
	_nQtdReq 	:= acols[n,_nPosHQ]
	
Else
	_cPedido 	:= SC7->C7_NUM
	_cProduto 	:= SC7->C7_PRODUTO
	_cLocal 	:= SC7->C7_LOCAL


IIF(Findfunction('u_monPrcPer'), StartJob('U_monPrcPer', GetEnvServer(), .F., 'MT120OK.prw', ''), '') //INCLUSAO AUTOMATICA POR TOTVSIP FORTMONPROC --GUSTAVO LUIZ


	_cItem 	:= SC7->C7_ITEM
	_nQtdReq 	:= SC7->C7_QUANT

EndIf

	_nMedPon 		:= MedPondG(_cProduto) //Posicione("SBZ",1,XFILIAL("SBZ")+_cProduto,"BZ_YMEDPON")
	_nEstAtu		:= EstAtuCruG(_cProduto) //StaticCall(VIXA113, EstAtual, _cProduto)
	_SldPed1		:= SaldoPed(_cPedido, _cProduto, _cLocal, _cItem) //StaticCall(MS170QTD, GetSalPed, _cProduto, _cLocal)
	_nDiasEst		:= ( (_nEstAtu + _nQtdReq + _SldPed1)  /_nMedPon) * 30	//_nQtdPend

Return (Round( _nDiasEst, 0))

//Funcao para apagar quantidade liberada
//quando for uma copia de pedido de compra
Static Function QTDLIBZERO()

Local _nPosHLB 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_YQTDLIB"})
Local _nX			:= 0

For _nX := 1 to Len(aCols)
	
	Acols[_nX,_nPosHLB] := 0

Next _nX


Return

//Retornar M้dia Poderada do produto
//Considera tamb้m c๓digo cru
Static Function MedPondG(_cProduto)

Local _cCodCru := ""
Local _nMedPondG := 0
Local _cGrupo := ""


	SZP->(dbSetOrder(2))
	If SZP->(dbSeek(xFilial("SZP")+_cProduto)) .and. SZP->ZP_AGLUCOM == "S"
			
		//Recupera C๓digo CRU
		_cCodCru := SZP->ZP_CRU
		_cGrupo := SZP->ZP_GRUPCOM
				
		SZP->(dbSetOrder(1))
		SZP->(dbSeek(xFilial("SZP")+_cCodCru))
				
		Do While SZP->(!Eof()) .and. xFilial("SZP")+_cCodCRu == SZP->ZP_FILIAL+SZP->ZP_CRU
				
			If SZP->ZP_AGLUCOM == "S" .AND. SZP->ZP_GRUPCOM = _cGrupo

				_nMedPondG += Posicione("SBZ",1,XFILIAL("SBZ")+SZP->ZP_PRODUTO,"SBZ->BZ_YMEDPON")		        	                            
									        		
			EndIf
									
			SZP->(dbSkip())
				
		EndDo
				
	Else
		_nMedPondG := Posicione("SBZ",1,XFILIAL("SBZ")+_cProduto,"SBZ->BZ_YMEDPON") 
	EndIf

Return _nMedPondG


//Retornar estoque do c๓digo CRU
//apenas que fazem parte do grupo e aglutina compras
Static Function EstAtuCruG(_cProduto)

Local _cCodCru := ""
Local _nEstCruGP := 0
Local _cGrupo := ""


	SZP->(dbSetOrder(2))
	If SZP->(dbSeek(xFilial("SZP")+_cProduto)) .and. SZP->ZP_AGLUCOM == "S"
			
		//Recupera C๓digo CRU
		_cCodCru := SZP->ZP_CRU
		_cGrupo := SZP->ZP_GRUPCOM
				
		SZP->(dbSetOrder(1))
		SZP->(dbSeek(xFilial("SZP")+_cCodCru))
				
		Do While SZP->(!Eof()) .and. xFilial("SZP")+_cCodCRu == SZP->ZP_FILIAL+SZP->ZP_CRU
				
			If SZP->ZP_AGLUCOM == "S" .AND. SZP->ZP_GRUPCOM = _cGrupo

				_nEstCruGP += StaticCall(MS170QTD, GetEstAtu, SZP->ZP_PRODUTO)		        	                            
									        		
			EndIf
									
			SZP->(dbSkip())
				
		EndDo
				
	Else
		_nEstCruGP := StaticCall(VIXA113, EstAtual, _cProduto) 
	EndIf

Return _nEstCruGP


//Retornar estoque do c๓digo CRU
//Considera todos os CRU's
Static Function EstAtuCrut(_cProduto)

Local _cCodCru := ""
Local _nEstCruGT := 0
Local _cGrupo := ""


	SZP->(dbSetOrder(2))
	If SZP->(dbSeek(xFilial("SZP")+_cProduto))
			
		//Recupera C๓digo CRU
		_cCodCru := SZP->ZP_CRU
				
		SZP->(dbSetOrder(1))
		SZP->(dbSeek(xFilial("SZP")+_cCodCru))
				
		Do While SZP->(!Eof()) .and. xFilial("SZP")+_cCodCRu == SZP->ZP_FILIAL+SZP->ZP_CRU
				
			_nEstCruGT += StaticCall(VIXA113, EstoqTot, SZP->ZP_PRODUTO) //EstAtual		        	                            
			SZP->(dbSkip())
				
		EndDo
				
	Else
		
		_nEstCruGT := StaticCall(VIXA113, EstAtual, _cProduto) 
	
	EndIf

Return _nEstCruGT


//Para inicializador padrao 
//campo quantidade pendente
Static Function SaldoPed2()

Local _aArea := GetArea()
Local _nSaldo2 := 0
Local _nQtdAnt := 0

//Verifica posicao dos campos no aheader
//Local _nPosHI 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_ITEM"})
//Local _nPosHP 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_PRODUTO"})
//Local _nPosHL 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_LOCAL"})
//Local _nPosHQ 	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "C7_QUANT"}) 

Local _cPedido := CA120NUM
Local _cProduto := SC7->C7_PRODUTO //acols[n,_nPosHP]//SC7->C7_PRODUTO
Local _clocal := SC7->C7_LOCAL //acols[n,_nPosHL] //SC7->C7_LOCAL
Local _cItem := SC7->C7_ITEM //acols[n,_nPosHI] //SC7->C7_ITEM

If AllTrim(_cProduto) == ''
	Return 0
Endif

_nSaldo2 	:= StaticCall(MS170QTD, GetSalPed, _cProduto, _cLocal)

	If (!INCLUI .AND. !ALTERA)
		_nQtdAnt := SC7->C7_QUANT
	Else
		_nQtdAnt := Posicione("SC7",1,xFilial("SC7")+ _cPedido + _cItem,"C7_QUANT")
	EndIf
	
_nSaldo2 := _nSaldo2 - _nQtdAnt
_nSaldo2 += MTSB2(_cProduto)


RestArea(_aArea)

Return (_nSaldo2)

//Saldo SB2
Static Function MTSB2(_cProd)

Local _aArea := GetArea()
Local _nSaldo := 0

DbSelectArea("SB2")
SB2->(DbSetOrder(1))
IF SB2->(DbSeek(xfilial("SB2")+_cProd+"01"))
	_nSaldo := SB2->B2_NAOCLAS
EndIf

RestArea(_aArea)

Return (_nSaldo)
