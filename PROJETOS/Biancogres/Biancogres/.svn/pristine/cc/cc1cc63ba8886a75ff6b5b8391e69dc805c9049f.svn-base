#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TBiaEstoque
@author Artur Antunes
@since 09/02/2017
@version 1.0
@description Classe Generica
@obs OS: 0243-16 / 0137-17 / 1215-17
@type Class
/*/

Class TBiaEstoque from LongClassName

	Data cTxtLog
	
	Method New() Constructor
	Method FSTransfere(aItens)  // Transferencia de materiais SD3                 
	Method MovInterno(aItens) // Movimentação interna de materiais SD3
	Method ProxDocSD3()       // Proximo numero disponivel Sd3           

EndClass


Method New() CLASS TBiaEstoque
	::cTxtLog := ""
Return


Method FSTransfere(_aItens) Class TBiaEstoque

/*
_aItens
 1= Produto
 2= Local Origem
 3= local Destino
 4= Lote
 5= Localização
 6= Quantidade
 7= ID ( campo D3_YIDECO )
*/
local nx				:= 0
local lRet				:= len(_aItens) > 0
local cDoc 				:= ''
local aAuto				:= {}
local cErro 			:= ''
local aErro				:= {}
local aItem 			:= {}
local cProd				:= ''
local cLote				:= ''
local cLocal			:= ''
local cProdDest			:= ''
local cLoteDest			:= ''
local cLocalDest		:= ''
local cB1DesOri   		:= ''
local cB1UmOri 			:= ''
local cB1LozOri 		:= ''
local cB1RasOri 		:= ''
local cB1DesDest  		:= ''
local cB1UmDest 		:= ''
local cB1LozDest 		:= ''
local cB1RasDest 		:= ''
local dDtValid			:= stod('')
local dDtVDest			:= Stod('')
Private lMsErroAuto     := .F.            
Private lMSHelpAuto     := .T.
Private lAutoErrNoFile  := .T.
Private INCLUI          := .T.

::cTxtLog := ''
if lRet
	DbSelectArea('SB1')
	DbSelectArea('SB2')
	DbSelectArea('SB8')
	
	cDoc := ::ProxDocSD3()

	aadd(aAuto,{cDoc,dDataBase})
	
	For nx := 1 To Len(_aItens)
		if lRet

			cProd  		:= PADR(_aItens[nx,1],TAMSX3("B1_COD")[1])
			cLote  		:= PADR(_aItens[nx,4],TAMSX3("D3_LOTECTL")[1])
			cLocal 		:= PADR(_aItens[nx,2],TAMSX3("D3_LOCAL")[1])
			cProdDest  	:= ''
			cLoteDest  	:= ''
			cLocalDest 	:= ''
			
			if Len(_aItens[nx]) >= 8
				cProdDest := PADR(_aItens[nx,8],TAMSX3("B1_COD")[1])
			endif
			if Empty(cProdDest)
				cProdDest := cProd
			endif
			
			if Len(_aItens[nx]) >= 9
				cLoteDest := PADR(_aItens[nx,9],TAMSX3("D3_LOTECTL")[1])
			endif
			if Empty(cLoteDest)
				cLoteDest := cLote
			endif

			cLocalDest := PADR(_aItens[nx,3],TAMSX3("D3_LOCAL")[1])
			if Empty(cLocalDest)
				cLocalDest := cLocal
			endif
					
			SB1->(DbSetOrder(1))
			If !SB1->( DbSeek(xFilial("SB1")+cProd )) .and. lRet
				::cTxtLog += "ERRO: Produto " + cProd +" Não Encontrado" 
				lRet := .F.
			endif     

			SB1->(DbSetOrder(1))
			If !SB1->( DbSeek(xFilial("SB1")+cProdDest )) .and. lRet
				::cTxtLog += "ERRO: Produto " + cProdDest +" Não Encontrado" 
				lRet := .F.
			endif     

			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek( xFilial('SB2') + cProdDest + cLocalDest )) .and. lRet
				CriaSB2(cProdDest,cLocalDest)
				If !SB2->(DbSeek( xFilial('SB2')+ cProdDest + cLocalDest ))
					::cTxtLog += "Erro: Criacao do armazem destino: " + cLocalDest 
					lRet := .F.
				endif
			endif
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek( xFilial("SB1")+cProd )) 
			cB1DesOri   := SB1->B1_DESC
			cB1UmOri 	:= SB1->B1_UM
			cB1LozOri 	:= SB1->B1_LOCALIZ
			cB1RasOri 	:= SB1->B1_RASTRO
	
			SB1->(DbSetOrder(1))
			SB1->(DbSeek( xFilial("SB1")+cProdDest )) 
			cB1DesDest  := SB1->B1_DESC
			cB1UmDest 	:= SB1->B1_UM
			cB1LozDest 	:= SB1->B1_LOCALIZ
			cB1RasDest 	:= SB1->B1_RASTRO
						
			SB8->(DbSetOrder(3)) 
			if SB8->( DbSeek( xFilial("SB8") + cProd + cLocal + cLote ))
				dDtValid := SB8->B8_DTVALID
			endif
			
			if SB8->( DbSeek( xFilial("SB8") + cProdDest + cLocalDest + cLoteDest ))
				dDtVDest := SB8->B8_DTVALID
			Else
				dDtVDest :=	dDtValid
			EndIf
			
			If lRet
				aItem := {}
				
				aadd(aItem, cProd			)   //D3_COD		
				aadd(aItem, cB1DesOri		)   //D3_DESCRI				
				aadd(aItem, cB1UmOri		)  	//D3_UM			
				aadd(aItem, cLocal			)   //D3_LOCAL		
				if cB1LozOri == 'S'
					aadd(aItem, _aItens[nx,5] 	)	//D3_LOCALIZ	
				else
					aadd(aItem, "" 				)	//D3_LOCALIZ	
				endif		
				aadd(aItem,	cProdDest		)   //D3_COD		
				aadd(aItem, cB1DesDest		)   //D3_DESCRI				
				aadd(aItem, cB1UmDest		)  	//D3_UM			
				aadd(aItem, cLocalDest		)   //D3_LOCAL		
				if cB1LozDest == 'S'
					aadd(aItem, _aItens[nx,5] 	)	//D3_LOCALIZ	
				else
					aadd(aItem, "" 				)	//D3_LOCALIZ	
				endif		
				aadd(aItem, ""				)   //D3_NUMSERI	
				if cB1RasOri == "L"
					aadd(aItem, cLote			)	//D3_LOTECTL  	
				else
					aadd(aItem, ""				)	//D3_LOTECTL  	
				endif		
				aadd(aItem, ""				)   //D3_NUMLOTE		
				aadd(aItem, dDtValid		)	//D3_DTVALID		
				aadd(aItem, 0				)	//D3_POTENCI
				aadd(aItem, _aItens[nx,6]	) 	//D3_QUANT		
				aadd(aItem, 0				)	//D3_QTSEGUM		
				aadd(aItem, ""				)   //D3_ESTORNO
				aadd(aItem, ""				)   //D3_NUMSEQ 		
				if cB1RasDest == "L"
					aadd(aItem, cLoteDest		)	//D3_LOTECTL  	
				else
					aadd(aItem, ""				)	//D3_LOTECTL  	
				endif		
				aadd(aItem, dDtVDest		)	//D3_DTVALID
				aadd(aItem, ""				)	//D3_ITEMGRD
//				aadd(aItem, ""				)	//D3_IDDCF	
				aadd(aItem, ""				)	//D3_OBSERVA	
				if len(_aItens[nx]) >= 7
					aadd(aItem, _aItens[nx,7]	)   //D3_YIDECO
				else
					aadd(aItem, 0				)	//D3_YIDECO  	
				endif		

				aadd(aAuto,aItem)	
			endif
		endif	
	next nx
	
	if lRet
		lMsErroAuto := .F.  
		MSExecAuto({|x,y| mata261(x,y)},aAuto,3)				
	
		If lMsErroAuto
			aErro := GetAutoGRLog()
			For nX := 1 To Len(aErro)
				cErro += aErro[nX]+CRLF
			Next nX
			::cTxtLog += "ERRO MSExecAuto: " + CRLF + cErro
			lRet := .F.
		Else
			::cTxtLog += cDoc 
		EndIf
	endif
endif
return lRet


Method MovInterno(_aItens) Class TBiaEstoque
/*
_aItens
01= TM
02= CENTRO DE CUSTO
03= CLASSE VALOR
04= PRODUTO
05= LOTE 
06= LOCAL
07= QUANTIDADE
08= CONTA
09= VALIDADE DO LOTE
10= LOCALIZAÇÃO
11= OP
12= FUNÇÃO
13= ID ECOSIS (não obrigatorio)
 */
local nx				:= 0
local lRet				:= len(_aItens) > 0
local cDoc 				:= ''
local aTemp				:= {}
local cErro 			:= ''
local aErro				:= {}
local aItem 			:= {}
local cProd				:= ''
local cLote				:= ''
local aCab				:= {}
Private lMsErroAuto     := .F.            
Private lMSHelpAuto     := .T.
Private lAutoErrNoFile  := .T.
Private _ExecAutoII		:= .T. //Variavel para desativar Execblock velhos

::cTxtLog := ''
if lRet

	cDoc := ::ProxDocSD3()
		
	aCab :=	{	{"D3_DOC"     , cDoc		  	, NIL},;
				{"D3_TM"      , _aItens[1,1] 	, NIL},;
				{"D3_CC"      , _aItens[1,2] 	, NIL},;
				{"D3_CLVL"    , _aItens[1,3] 	, NIL},;
				{"D3_YSI"     ,''				, NIL},;
				{"D3_EMISSAO" , dDatabase	  	, NIL}}

	DbSelectArea('SB1')
	DbSelectArea('SB2')
	
	For nx := 1 To Len(_aItens)

		if lRet
			cProd  := PADR(_aItens[nx,4],TAMSX3("D3_COD")[1])
			cLote  := PADR(_aItens[nx,5],TAMSX3("D3_LOTECTL")[1])
			cLocal := PADR(_aItens[nx,6],TAMSX3("D3_LOCAL")[1])
		
			SB1->(DbSetOrder(1))
			If !SB1->( DbSeek(xFilial("SB1")+cProd )) .and. lRet
				::cTxtLog += "ERRO: Produto " + cProd +" Não Encontrado" 
				lRet := .F.
			endif     

			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek( xFilial('SB2')+cProd+cLocal )) .and. lRet
				CriaSB2(cProd,cLocal)
				If !SB2->(DbSeek( xFilial('SB2')+ cProd + cLocal ))
					::cTxtLog += "Erro: Criacao do armazem: "+ cLocal
					lRet := .F.
				endif
			endif
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek( xFilial("SB1")+cProd )) 
						
			If lRet
				aTemp := {}
				
				aAdd(aTemp,{"D3_COD"	  	, cProd         	,NIL})
				aAdd(aTemp,{"D3_DESCRI"	  	, SB1->B1_DESC  	,NIL})
				aAdd(aTemp,{"D3_UM"	  		, SB1->B1_UM		,NIL})
				aAdd(aTemp,{"D3_QUANT"  	, _aItens[nx,7]  	,NIL})
				aAdd(aTemp,{"D3_LOCAL"  	, cLocal		  	,NIL})
				aAdd(aTemp,{"D3_CONTA" 		, _aItens[nx,8]  	,NIL})
				aAdd(aTemp,{"D3_USUARIO"	, cUserName			,NIL})
				aAdd(aTemp,{"D3_CC"			, _aItens[nx,2]		,NIL})
				aAdd(aTemp,{"D3_CLVL"		, _aItens[nx,3] 	,NIL})
				aAdd(aTemp,{"D3_LOTECTL"	, cLote			 	,NIL})
				aAdd(aTemp,{"D3_DTVALID"	, _aItens[nx,9]	 	,NIL})
				aAdd(aTemp,{"D3_LOCALIZ"	, _aItens[nx,10] 	,NIL})
				aAdd(aTemp,{"D3_SEGUM"  	, SB1->B1_SEGUM		,NIL})
				aAdd(aTemp,{"D3_OP"	    	, _aItens[nx,11] 	,NIL})
				aAdd(aTemp,{"D3_YRFCUST" 	, _aItens[nx,12]	,NIL})
				if len(_aItens[nx]) >= 13
					aAdd(aTemp,{"D3_YIDECO" 	, _aItens[nx,13]	,NIL})
				endif	
				aAdd(aTemp,{"D3_USUARIO"  	, "ECOSIS_AUTO"		,NIL})
				aAdd(aItem, aTemp)

			endif
		endif	
	next nx
	
	if lRet
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem)			
	
		If lMsErroAuto
			aErro := GetAutoGRLog()
			For nX := 1 To Len(aErro)
				cErro += aErro[nX]+CRLF
			Next nX
			::cTxtLog += "ERRO MSExecAuto: " + CRLF + cErro
			lRet := .F.
		Else
			::cTxtLog += cDoc 
		EndIf
	endif
endif

return lRet


Method ProxDocSD3() Class TBiaEstoque

local aArea  	 := GetArea()
local nOrder 	 := 0
local cDocumento := UPPER( NextNumero("SD3",2,"D3_DOC",.T.) )
local cMay		 := ''
local lFirstNum  := .T.
local nRecno	 := 0

dbSelectArea('SD3')
nOrder := IndexOrd()
nRecno := SD3->(Recno())
SD3->(dbSetOrder(2))
cMay := "SD3"+Alltrim(xFilial('SD3'))+cDocumento

While SD3->(dbSeek(xFilial('SD3')+cDocumento)) .Or. !MayIUseCode(cMay)

	If lFirstNum
		cDocumento := UPPER( NextNumero("SD3",2,"D3_DOC",.T.) )
		cDocumento := A261RetINV(cDocumento)
		lFirstNum :=.F.
	Else
		cDocumento := Soma1(cDocumento)
	EndIf
	
	cMay := "SD3"+Alltrim(xFilial('SD3'))+cDocumento
EndDo

ConfirmSX8()

SD3->(dbSetOrder(nOrder))
SD3->(dbgoto(nRecno))
RestArea(aArea)
return cDocumento
