#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} TMovimentacaoInterna
//TODO Descrição auto-gerada.
@author Pedro Henrique
@since 26/02/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/

Class TMovimentacaoInterna From LongClassName

	Data nOpcao		

	Data cDocumento		
	Data cProd
	Data cLocal
	Data nQuant
	Data cClasseVr
	Data cCC
	Data cTipoMov
	Data dDataEmis
	Data nIdEco
	Data cLocaliza
	Data cLoteCtl
	Data cOriMov
	Data cTag
	Data cAplica
	Data cMatric

	Data cLog
	Data cMensagem
	Data lOk	

	Method New(nOpcao, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza, cOriMov, cTag, cAplica, cMatric, cCC, cLoteCtl) Constructor
	Method Executar()
	Method GetSaldo()

EndClass

Method New(nOpcao, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza, cOriMov, cTag, cAplica, cMatric, cCC, cLoteCtl) Class TMovimentacaoInterna	

	Default cCC	:= "3000"
	Default cLoteCtl := ""

	::cLog		:= ""
	::cMensagem	:= ""
	::lOk		:= .T.

	::nOpcao		:= nOpcao
	::cDocumento	:= GetSxeNum("SD3", "D3_DOC") 		

	DbSelectArea("SD3")
	SD3->(dbSetOrder(2))
	If SD3->(dbSeek(xFilial("SD3") + ::cDocumento))
		While .T.
			::cDocumento    := GetSxeNum("SD3", "D3_DOC")
			SD3->(dbSetOrder(2))
			If !SD3->(dbSeek(xFilial("SD3") + ::cDocumento))
				Exit
			EndIf
		EndDo
	EndIf

	::cProd			:= cProd
	::cLocal		:= cLocal
	::nQuant		:= nQuant
	::cClasseVr		:= cClasseVr
	::cCC			:= cCC	
	::cTipoMov		:= cTipoMov
	::nIdEco		:= nIdEco
	::cLocaliza		:= cLocaliza
	::cLoteCtl		:= cLoteCtl
	::cOriMov		:= cOriMov
	::cTag			:= cTag
	::cAplica		:= cAplica
	::cMatric		:= cMatric
	::dDataEmis		:= IIF(Empty(dDataEmis) .Or. dDataEmis == Nil, dDataBase, dDataEmis) 		

Return(Self)

Method GetSaldo() Class TMovimentacaoInterna

	Local aArea			:= SB2->(GetArea())
	Local nSaldo		:= 0

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))

	If SB2->(DbSeek(xFilial("SB2") + PADR(::cProd, TamSx3("B1_COD")[1]) + ::cLocal))

		nSaldo := (SB2->B2_QATU - SB2->B2_RESERVA -  SB2->B2_QACLASS)

	EndIf

	SB2->(DbCloseArea())

	SB2->(RestArea(aArea))

Return nSaldo


Method Executar() Class TMovimentacaoInterna

	Local aMovimento 	:= {}
	Local cPath			:= GetSrvProfString("Startpath","")
	Local cFileLog		:= Criatrab(,.F.) + ".log"
	Local nSaldo		:= ::GetSaldo()
	Local cDataHora	:=	""


	Private lMsErroAuto := .F.
	Private _IViaEAuto	:= .T.

	::cLog += "Produto		: " + ::cProd + CRLF 
	::cLog += "Quantidade	: " + cvaltochar(::nQuant) + CRLF
	::cLog += "Classe Valor	: " + ::cClasseVr + CRLF

	Begin Transaction   	

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1") + ::cProd))

			//Validação de Conta contábil
			cMelhor := '1'
			cConta	:= "" 
			If U_B478RTCC(::cClasseVr)[2] == "D"
				cConta	:= SB1->B1_YCTRADM

			ElseIf U_B478RTCC(::cClasseVr)[2] == "C"
				cConta  := SB1->B1_YCTRIND

			ElseIf U_B478RTCC(::cClasseVr)[2] $ "A/I"
				cConta  := "16503" + Substr(::cClasseVr,2,8)

			EndIf

			IF ::cAplica == '4' .AND. !EMPTY(cMelhor) .AND. Subs(::cClasseVr,1,1) == "3"
				cConta := '61301010'
			ENDIF

			If SB1->B1_GRUPO == '107A' .Or. SB1->B1_GRUPO == '107E' 
				If Alltrim(::cClasseVr) == "3117" .Or. Alltrim(::cClasseVr) == "3135" .Or. Alltrim(::cClasseVr) == "3217"
					cConta :=	"61110006" 
				ElseIf Alltrim(::cClasseVr) == "3136" 
					cConta	:=	"61110001"
				EndIf
			EndIf	

			If (::nQuant <= nSaldo)

				aMovimento := {}
				aAdd(aMovimento,{"D3_DOC"	 	,::cDocumento	,NIL})
				aAdd(aMovimento,{"D3_TM"     	,::cTipoMov		,NIL})
				aAdd(aMovimento,{"D3_EMISSAO"	,::dDataEmis	,NIL})
				aAdd(aMovimento,{"D3_CC"     	,::cCC			,NIL})
				aAdd(aMovimento,{"D3_CLVL"   	,::cClasseVr	,NIL})

				If (::nIdEco <> 0)
					aAdd(aMovimento,{"D3_YIDECO" 	,::nIdEco		,NIL})
				EndIf

				cDataHora	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"

				aAdd(aMovimento,{"D3_CONTA"		,cConta			,NIL})
				aAdd(aMovimento,{"D3_COD"		,SB1->B1_COD	,NIL})
				aAdd(aMovimento,{"D3_UM"		,SB1->B1_UM		,NIL})
				aAdd(aMovimento,{"D3_QUANT"  	,::nQuant		,NIL})
				aAdd(aMovimento,{"D3_LOCAL" 	,::cLocal	    ,NIL})
				aAdd(aMovimento,{"D3_LOCALIZ"	,::cLocaliza 	,NIL})
				aAdd(aMovimento,{"D3_LOTECTL"	,::cLoteCtl		,NIL})
				aAdd(aMovimento,{"D3_YORIMOV"	,::cOriMov		,NIL}) 
				aAdd(aMovimento,{"D3_YTAG"   	,::cTag			,NIL}) 
				aAdd(aMovimento,{"D3_YAPLIC"	,::cAplica		,NIL}) 
				aAdd(aMovimento,{"D3_YMATRIC"	,::cMatric		,NIL})
				aAdd(aMovimento,{"D3_YDHMOV"	,	cDataHora	,NIL}) 

				MSExecAuto({|x,y| MATA240(x,y)},aMovimento, ::nOpcao)

				If lMsErroAuto

					::cLog	+= "Mensagem		: " + AllTrim(MostraErro(cPath, cFileLog))+CRLF
					::lOk	:= .F.
					::cMensagem	:= "Erro ao gravar movimentação."

				Else

					::cLog	+= "Mensagem		: " + "Processo concluido." + CRLF
					::lOk	:= .T.				
					::cMensagem	:= "Movimentação concluida com sucesso."

				EndIf

			Else

				::cLog	+= "Mensagem		: " + "Produto não tem saldo suficiente. Saldo: "+cvaltochar(nSaldo)+"." + CRLF
				::lOk	:= .F.
				::cMensagem	:= "Produto não tem saldo suficiente. Saldo: "+cvaltochar(nSaldo)+"."

			EndIf		

		Else

			::cLog	+= "Mensagem		: " + "Produto não encontrado." + CRLF
			::lOk	:= .F.
			::cMensagem	:= "Produto não encontrado."		

		EndIf


		SB1->(DbCloseArea())
	End Transaction

Return()
