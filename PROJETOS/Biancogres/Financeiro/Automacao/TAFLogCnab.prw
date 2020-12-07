#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFLogCnab
@author Tiago Rossini Coradini
@since 23/10/2018
@project Automação Financeira
@version 1.0
@description Classe para inclusao de log de procedimentos
@type class
/*/

Class TAFLogCnab From LongClassName

	Data cEmp		
	Data cFil    	
	Data dData		
	Data cBordeDe	
	Data cBordeAte
	Data cBanco
	Data cAgencia
	Data cConta
	Data cSubcta
	Data cArqcfg 	
	Data cArqUser	
	Data cLayout
	Data cUser   	
	Data cMsgCnab	
	
	Data nRecNo
	
	Method New() Constructor
	Method SetProperty()
	Method Insert()
	Method Update()
	Method Save(lNew)

EndClass


Method New() Class TAFLogCnab

	::SetProperty()

Return()


Method SetProperty() Class TAFLogCnab
	
	::cEmp		:= cEmpAnt
	::cFil      := cFilAnt
	::dData		:= dDataBase
	::cBordeDe  := ""
	::cBordeAte := ""
	::cBanco	:= ""
	::cAgencia  := ""
	::cConta    := ""
	::cSubcta   := ""
	::cArqcfg   := ""
	::cArqUser  := ""
	::cLayout	 := ""
	::cUser     := __cUserId
	::cMsgCnab  := ""
	
	::nRecNo 	 := 0
	 
Return()


Method Insert() Class TAFLogCnab

	::Save(.T.)

Return()


Method Update() Class TAFLogCnab

	If ::nRecNo > 0

		DbSelectArea("ZK3")
		ZK3->(DbGoTo(::nRecNo))

		::Save(.F.)

	EndIf

Return()


Method Save(lNew) Class TAFLogCnab

	Default lNew := .T.

	RecLock("ZK3", lNew)
	
		ZK3->ZK3_FILIAL	:= xFilial("ZK3")
		ZK3->ZK3_FIL    := ::cFil
		ZK3->ZK3_EMP    := ::cEmp
		ZK3->ZK3_DATA   := ::dData
		ZK3->ZK3_BORDE  := ::cBordeDe
		ZK3->ZK3_BORATE := ::cBordeAte
		ZK3->ZK3_BANCO 	:= ::cBanco	
		ZK3->ZK3_AGENCI := ::cAgencia 
		ZK3->ZK3_CONTA 	:= ::cConta   
		ZK3->ZK3_SUBCTA := ::cSubcta  
		ZK3->ZK3_ARQCFG := ::cArqcfg
		ZK3->ZK3_ARQUSE := ::cArqUser
		ZK3->ZK3_LAYOUT := ::cLayout 
		ZK3->ZK3_USER   := ::cUser
		ZK3->ZK3_MSGCNA	:= ::cMsgCnab
		
	ZK3->(MsUnLock())

	::nRecNo := ZK3->(RecNo())

	//::SetProperty()

Return()