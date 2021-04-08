#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FIDC002()

	RpcSetEnv('01', '01')


	oCPRStruct					:=  TContaPagarRastreabilidadeStruct():New()
	oCPRStruct:cFilOri 			:= "01"
	oCPRStruct:cPrefOri 		:= "5"
	oCPRStruct:cNumOri			:= "000012393"
	oCPRStruct:cParOri          := ""
	oCPRStruct:cTipoOri         := "NF"
	oCPRStruct:cForneceOri      := "010098"
	oCPRStruct:cLojaOri         := "01"
	
	oCPRStruct:cFilDest         := "01"
	oCPRStruct:cPrefDest        := "FDC"
	oCPRStruct:cNumDest         := "000000001"
	oCPRStruct:cParDest         := ""
	oCPRStruct:cTipoDest        := "NF"
	oCPRStruct:cForneceDest     := "014161"
	oCPRStruct:cLojaDest        := "01"
	
	oCPRStruct:nValor           := 1000
	oCPRStruct:dData            := dDataBase
	oCPRStruct:cStatus          := '0' //0=Ativo
	

	oContaPagarRast	:=  TContaPagarRastreabilidade():New()
	oResult 		:= oContaPagarRast:Incluir(oCPRStruct)
	
	If (oResult:lOk)
		MsgAlert('<p style="color:green">'+oResult:cMensagem+'</p>', 'Sucesso')
	Else
		MsgAlert('<p style="color:red">'+oResult:cMensagem+'</p>', 'Erro')
	EndIf
	
Return 



Class TContaPagarRastreabilidade From LongClassName
	
	Public Data oObj
	Public Data oResult
	
	Method New() Constructor
	Method Incluir() 

EndClass

Method New() Class TContaPagarRastreabilidade
	::oObj		:= Nil
	::oResult	:= TContaPagarRastreabilidadeResultStruct():New()
Return()



Method Incluir(_oObj) Class TContaPagarRastreabilidade

	Local lOk				:= .F.
	Local cMsgLog			:= ""
	
	
	::oObj 			:= _oObj

	
	varinfo("::oObj", ::oObj )
	
	::oObj:cFilOri 				:= PADR(::oObj:cFilOri			, TamSX3("FI8_FILIAL")[1])
	::oObj:cPrefOri 			:= PADR(::oObj:cPrefOri			, TamSX3("FI8_PRFORI")[1])
	::oObj:cNumOri				:= PADR(::oObj:cNumOri			, TamSX3("FI8_NUMORI")[1])
	::oObj:cParOri           	:= PADR(::oObj:cParOri			, TamSX3("FI8_PARORI")[1])
	::oObj:cTipoOri          	:= PADR(::oObj:cTipoOri			, TamSX3("FI8_TIPORI")[1])
	::oObj:cForneceOri       	:= PADR(::oObj:cForneceOri		, TamSX3("FI8_FORORI")[1])
	::oObj:cLojaOri          	:= PADR(::oObj:cLojaOri			, TamSX3("FI8_LOJORI")[1])
	::oObj:cFilDest          	:= PADR(::oObj:cFilDest			, TamSX3("FI8_FILDES")[1])
	::oObj:cPrefDest         	:= PADR(::oObj:cPrefDest		, TamSX3("FI8_PRFDES")[1])
	::oObj:cNumDest          	:= PADR(::oObj:cNumDest			, TamSX3("FI8_NUMDES")[1])
	::oObj:cParDest          	:= PADR(::oObj:cParDest			, TamSX3("FI8_PARDES")[1])
	::oObj:cTipoDest         	:= PADR(::oObj:cTipoDest		, TamSX3("FI8_TIPDES")[1])
	::oObj:cForneceDest      	:= PADR(::oObj:cForneceDest		, TamSX3("FI8_FORDES")[1])
	::oObj:cLojaDest         	:= PADR(::oObj:cLojaDest		, TamSX3("FI8_LOJDES")[1])
	
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1)) //E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_D_E_L_
	
	_cChaveOri := ::oObj:cFilOri
	_cChaveOri += ::oObj:cPrefOri
	_cChaveOri += ::oObj:cNumOri
	_cChaveOri += ::oObj:cParOri   
	_cChaveOri += ::oObj:cTipoOri
	_cChaveOri += ::oObj:cForneceOri
	_cChaveOri += ::oObj:cLojaOri
	
	_cChaveDest := ::oObj:cFilDest
	_cChaveDest += ::oObj:cPrefDest
	_cChaveDest += ::oObj:cNumDest
	_cChaveDest += ::oObj:cParDest   
	_cChaveDest += ::oObj:cTipoDest
	_cChaveDest += ::oObj:cForneceDest
	_cChaveDest += ::oObj:cLojaDest

	lRetOri 	:=  SE2->(DbSeek(_cChaveOri))
	lRetDest 	:=  SE2->(DbSeek(_cChaveDest))
		
	 	
	If lRetOri
		If lRetDest
			
			DbSelectArea("FI8")
			
			FI8->(DbSetOrder(1)) 
			lRetOri :=  FI8->(DbSeek(_cChaveOri))
			
			FI8->(DbSetOrder(2)) 
			lRetDest :=  FI8->(DbSeek(_cChaveDest)) 
		
			If !lRetOri .Or. !lRetDest
			
				RecLock("FI8", .T.)
					FI8->FI8_FILIAL		:= ::oObj:cFilOri 
					FI8->FI8_PRFORI     := ::oObj:cPrefOri
					FI8->FI8_NUMORI     := ::oObj:cNumOri	
					FI8->FI8_PARORI     := ::oObj:cParOri 
					FI8->FI8_TIPORI     := ::oObj:cTipoOri   
					FI8->FI8_FORORI     := ::oObj:cForneceOri 
					FI8->FI8_LOJORI     := ::oObj:cLojaOri  
					FI8->FI8_FILDES     := ::oObj:cFilDest 
					FI8->FI8_PRFDES     := ::oObj:cPrefDest 
					FI8->FI8_NUMDES     := ::oObj:cNumDest 
					FI8->FI8_PARDES     := ::oObj:cParDest
					FI8->FI8_TIPDES     := ::oObj:cTipoDest 
					FI8->FI8_FORDES     := ::oObj:cForneceDest
					FI8->FI8_LOJDES     := ::oObj:cLojaDest
					FI8->FI8_VALOR      := ::oObj:nValor  
					FI8->FI8_STATUS     := ::oObj:cStatus
					FI8->FI8_DATA       := ::oObj:dData
					FI8->FI8_CHKORI     := ""
				FI8->(MsUnLock())
				
				lOk			:= .T.
				cMsgLog 	:= "[Conta a Pagar Rastreabilidade Origem Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilOri+'/'+::oObj:cPrefOri+'/'+::oObj:cNumOri+'/'+::oObj:cParOri+'/'+::oObj:cTipoOri+'/'+::oObj:cForneceOri+'/'+::oObj:cLojaOri+",  "+CRLF
				cMsgLog 	+= " Destino Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilDest+'/'+::oObj:cPrefDest+'/'+::oObj:cNumDest+'/'+::oObj:cParDest+'/'+::oObj:cTipoDest+'/'+::oObj:cForneceDest+'/'+::oObj:cLojaDest+"] => incluido com sucesso."
				
				::oResult:Add(lOk, cMsgLog)	
				
			Else
				cMsgLog 	:= "[Conta a Pagar Rastreabilidade Origem: Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilOri+'/'+::oObj:cPrefOri+'/'+::oObj:cNumOri+'/'+::oObj:cParOri+'/'+::oObj:cTipoOri+'/'+::oObj:cForneceOri+'/'+::oObj:cLojaOri+",  "+CRLF
				cMsgLog 	+= " Destino: Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilDest+'/'+::oObj:cPrefDest+'/'+::oObj:cNumDest+'/'+::oObj:cParDest+'/'+::oObj:cTipoDest+'/'+::oObj:cForneceDest+'/'+::oObj:cLojaDest+"] => ja existe."
					
			EndIf
					
			
		Else
			
			lOk			:= .F.
			cMsgLog 	:= "[Conta a Pagar Rastreabilidade  Destino: Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilDest+'/'+::oObj:cPrefDest+'/'+::oObj:cNumDest+'/'+::oObj:cParDest+'/'+::oObj:cTipoDest+'/'+::oObj:cForneceDest+'/'+::oObj:cLojaDest+"] => não existe."
		EndIf
		
	Else
			
		lOk			:= .F.
		cMsgLog 	:= "[Conta a Pagar Rastreabilidade Origem: Filial/Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cFilOri+'/'+::oObj:cPrefOri+'/'+::oObj:cNumOri+'/'+::oObj:cParOri+'/'+::oObj:cTipoOri+'/'+::oObj:cForneceOri+'/'+::oObj:cLojaOri+"] => não existe."
	EndIf
	
	::oResult:Add(lOk, cMsgLog)	

	
Return ::oResult	

Class TContaPagarRastreabilidadeStruct From LongClassName
	
	Public Data cFilOri 
	Public Data cPrefOri 
	Public Data cNumOri
	Public Data cParOri 
	Public Data cTipoOri 
	Public Data cForneceOri 
	Public Data cLojaOri
	
	Public Data cFilDest 
	Public Data cPrefDest 
	Public Data cNumDest
	Public Data cParDest 
	Public Data cTipoDest 
	Public Data cForneceDest 
	Public Data cLojaDest
	
	Public Data cStatus
	Public Data dData
	Public Data nValor
	
		
	Public Method New() Constructor
	
EndClass

Method New() Class TContaPagarRastreabilidadeStruct

	::cFilOri 			:= ""
	::cPrefOri 			:= ""
	::cNumOri			:= ""
	::cParOri           := ""
	::cTipoOri          := ""
	::cForneceOri       := ""
	::cLojaOri          := ""
	::cFilDest          := ""
	::cPrefDest         := ""
	::cNumDest          := ""
	::cParDest          := ""
	::cTipoDest         := ""
	::cForneceDest      := ""
	::cLojaDest         := ""
	::cStatus           := ""
	::dData             := dDataBase
	::nValor            := 0

Return()


Class TContaPagarRastreabilidadeResultStruct From LongClassName

	Data lOk			as logical
	Data cMensagem	as character
	Data cID			as numeric

	Method New() Constructor
	Method Add()

EndClass

Method New() Class TContaPagarRastreabilidadeResultStruct

	::lOk		:= .T.
	::cMensagem	:= ""
	::cID		:= 0

Return()

Method Add(lOk, cMensagem, cID) Class TContaPagarRastreabilidadeResultStruct

	::lOk		:= lOk
	::cMensagem	+= cMensagem
	::cID		:= cID

Return()
