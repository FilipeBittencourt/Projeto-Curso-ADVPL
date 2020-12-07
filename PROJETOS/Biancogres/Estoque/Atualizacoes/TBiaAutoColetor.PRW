#include "totvs.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "vkey.ch"
#define DS_MODALFRAME 128

/*/{Protheus.doc} TBiaAutoColetor
@author Fernando Rocha
@since 09/09/2015
@version 1.0
@description Classe para telas do Coletor de dados da baixa de Pre Requisicao
@type class
/*/

/*/{Protheus.doc} TBiaAutoColetor
@author Artur Antunes
@since 25/04/2017
@version 1.1
@description ajuste para inclusão de opção de manutenção de borderô
@obs OS 0104-17
@type class
/*/

User Function FCLA0014; Return()


Class TBiaAutoColetor From LongClassName

Data oBold11
Data oBold12
Data oBold16
Data oCour18
Data oBold20
Data oBold24

Data nSrcWidth
Data nSrcHeight

Data cUsuario
Data aMenu
Data cEmpSel
Data cUsuERP
Data lSetNewPsw
Data aAcessos
       
Method New() Constructor
Method GetFonts()
         
Method Start()   
   
//Tela de acesso do usuario
Method DlgUsuario()
//Tela de exibicao de mensagens
Method DlgMensagem(_cTexto,_cTitulo,_cTipo)
//carregar menu principal
Method LoadMenu() 
//tela de selecao do menu principal
Method DlgMenu()       

Method MenuActivate(nPos)   

//Metodo de validar usuario e senha
Method VldSenha(_cUsuario, _cSenha)

EndClass
 
 
//Construtor da Classe
Method New() Class TBiaAutoColetor

::GetFonts() 
  
//padrao de tamanho das telas para coletor
::nSrcWidth := 300
::nSrcHeight := 280

::cUsuario := ""
::lSetNewPsw := .F.
		
Return()


Method GetFonts() Class TBiaAutoColetor 

::oBold11 := TFont():New("Arial",,-11,,.T.)
::oBold12 := TFont():New("Arial",,-12,,.T.)
::oBold16 := TFont():New("Arial",,-16,,.T.)
::oCour18 := TFont():New("Courier",,-22,,.T.)
::oBold20 := TFont():New("Arial",,-20,,.T.)
::oBold24 := TFont():New("Arial",,-24,,.T.)

Return


//Tela de inicio do coletor
Method Start() Class TBiaAutoColetor

If ( ::DlgUsuario() )
	
	::LoadMenu()   
	If ( Len(::aMenu) > 0 )
		::DlgMenu()
	EndIf   

EndIf

RpcClearEnv()

Return


//Tela de Acesso do Usuario
Method DlgUsuario() Class TBiaAutoColetor

	Local 	lSenhaOk := .F.

	Local 	oDlgUsuario
	
	Local 	oLblSenha
	Local 	oLblUsuario
	Local 	oLblEmpresa
	
	Local	oUsuario
	Local 	oSenha
	Local 	oEmpresa
	
	Local	oConfirma
	Local	oCancela

	Local 	cTitulo := "Acesso Coletor Almoxarifado"	

	Local _cSenha	:= space(20)
	Local _cUsuario	:= Space(20)
	Local _cEmpresa	:= Space(02)
	Local _aComboEmp := {"Biancogres","Incesa"}
	Local _cComboEmp := _aComboEmp[1] 
	
	Local lVldSenha := .F.
	Local bClearScr := {||	_cUsuario := Space(20), _cSenha	 := space(20), oUsuario:Refresh(), oSenha:Refresh(), oUsuario:SetFocus() }
		    	
   	oDlgUsuario := TDialog():New(0, 0, 0, 0)
   	oDlgUsuario:nWidth		:= ::nSrcWidth
   	oDlgUsuario:nHeight		:= ::nSrcHeight
   	oDlgUsuario:cCaption 	:= cTitulo
   	oDlgUsuario:nStyle 		:= DS_MODALFRAME
	oDlgUsuario:lEscClose	:= .T.
			 
	//USUARIO
	oLblUsuario	:= TSay():Create(oDlgUsuario)
	oLblUsuario:nLeft 		:= 10
	oLblUsuario:nTop 		:= 20
	oLblUsuario:nWidth 		:= 210
	oLblUsuario:nHeight 	:= 30
	oLblUsuario:nClrText 	:= CLR_BLUE
	oLblUsuario:oFont 		:= ::oBold11
	oLblUsuario:SetText("Usuario:")
			  
	oUsuario	:= TGet():Create(oDlgUsuario)
	oUsuario:bSetGet 	:=  {|u| If(PCount() > 0, _cUsuario := u, _cUsuario) }
	oUsuario:nLeft 		:= 10
	oUsuario:nTop 		:= 45
	oUsuario:nWidth 	:= 210
	oUsuario:nHeight 	:= 30
	oUsuario:nClrText 	:= CLR_RED
	oUsuario:bWhen 		:= {|| .T. }
	oUsuario:oFont 		:= ::oBold16
	oUsuario:Picture	:= "@E 999"
			  
	//SENHA
	oLblSenha	:= TSay():Create(oDlgUsuario)
	oLblSenha:nLeft 		:= 10
	oLblSenha:nTop 			:= 80
	oLblSenha:nWidth 		:= 210
	oLblSenha:nHeight 		:= 30
	oLblSenha:nClrText 		:= CLR_BLUE
	oLblSenha:oFont 		:= ::oBold11
	oLblSenha:SetText("Senha:")
			  
	oSenha	:= TGet():Create(oDlgUsuario)
	oSenha:bSetGet 		:=  {|u| If(PCount() > 0, _cSenha := u, _cSenha) }
	oSenha:nLeft 		:= 10
	oSenha:nTop 		:= 105
	oSenha:nWidth 		:= 210
	oSenha:nHeight 		:= 30
	oSenha:nClrText 	:= CLR_RED
	oSenha:lPassWord 	:= .T.
   	oSenha:bWhen 		:= {|| .T. }
	oSenha:oFont 		:= ::oBold16
              
	oConfirma := TBUTTON():Create(oDlgUsuario)
	oConfirma:cCaption	:= "Confirmar"
	oConfirma:nLeft 	:= 40
	oConfirma:nTop 		:= 220
	oConfirma:nWidth 	:= 60
	oConfirma:nHeight 	:= 24
	oConfirma:bAction := {|| IIF( lSenhaOk := ::VldSenha(_cUsuario, _cSenha), oDlgUsuario:End(), Eval(bClearScr) ) }   
	
	oCancela := TBUTTON():Create(oDlgUsuario)
	oCancela:cCaption	:= "Cancelar"
	oCancela:nLeft 		:= 140
	oCancela:nTop 		:= 220
	oCancela:nWidth 	:= 60
	oCancela:nHeight 	:= 24
	oCancela:bAction	:= {|| oDlgUsuario:End() } 

	Eval(bClearScr)	
	oDlgUsuario:Activate(,,,.T. /*lCentered*/)
	
	If (lSenhaOk)
	
		::cUsuario := _cUsuario
		
	EndIf

Return( lSenhaOk )


//Validacao de Acesso de Usuario
Method DlgMensagem(_cTexto,_cTitulo,_cTipo) Class TBiaAutoColetor

	Local _uRet 
	Local oDlgmMsg
	Local _oConfBot
	Local _oApagBot
	Local _oCancBot
	
	Default _cTipo 		:= "ALERT" 
	Default _cTitulo	:= "Atenção!"
	
	//Janela
	oDlgmMsg := TDialog():New(0, 0, 0, 0)
   	oDlgmMsg:nWidth		:= ::nSrcWidth
   	oDlgmMsg:nHeight	:= ::nSrcHeight
   	oDlgmMsg:cCaption 	:= _cTitulo
   	oDlgmMsg:nStyle 	:= DS_MODALFRAME
	oDlgmMsg:lEscClose	:= .F.
	
	If Upper( _cTipo ) == "ALERT"
		
		_oConfBot := SButton():New( 110, 080,  1, {|| _uRet := .T., oDlgmMsg:End() }, oDlgmMsg, .T., , )
	
	ElseIf Upper( _cTipo ) == "NOYES"
	
		_oApagBot := SButton():New( 110, 050,  2, {|| _uRet := .F., oDlgmMsg:End() }, oDlgmMsg, .T., , )
		_oConfBot  := SButton():New( 110, 080,  1, {|| _uRet := .T., oDlgmMsg:End() }, oDlgmMsg, .T., , )
   
	ElseIf Upper( _cTipo ) == "YESNOCANC"
		
		_oConfBot  := SButton():New( 110, 020,  1, {|| _uRet := "1", oDlgmMsg:End() }, oDlgmMsg, .T., , )
		_oApagBot := SButton():New( 110, 050,  2, {|| _uRet := "2", oDlgmMsg:End() }, oDlgmMsg, .T., , )
		_oCancBot := SButton():New( 110, 080,  3, {|| _uRet := "3", oDlgmMsg:End() }, oDlgmMsg, .T., , )
   
   ElseIf Upper( _cTipo ) == "YESNO"
		
		_oConfBot  := SButton():New( 110, 050,  1, {|| _uRet := .T., oDlgmMsg:End() }, oDlgmMsg, .T., , )
		_oApagBot := SButton():New( 110, 080,  2, {|| _uRet := .F., oDlgmMsg:End() }, oDlgmMsg, .T., , )
				
   EndIf

	oMsg:= TMultiget():New(002, 002, {|u| IIf(Pcount() > 0, _cTexto := u, _cTexto)}, oDlgmMsg, 143, 105, ::oBold11, , , , , .T., , ,{||.F.})
	oMsg:lWordWrap 	:= .T.
	oMsg:bWhen     	:= {|| .F.}
	oMsg:EnableVScroll(.T.)	
	oMsg:EnableHScroll(.T.)

	Activate MsDialog oDlgmMsg Centered

Return( _uRet )


//Validacao de Acesso de Usuario
Method VldSenha(_cUsuario, _cSenha) Class TBiaAutoColetor
Local _cAliasTmp
Local lVldSenha := .T.
Local _cUserERP
local cTemp := ''

	//Seleciona e abre conexao com a empresa padrao
	RPCSetType(3)
	WfPrepEnv("01", "01")
	
	Z64->(DbSetOrder(1))
	If Z64->(DbSeek(XFilial("Z64")+_cUsuario)) .And.;
		( (Alltrim(_cSenha) == AllTrim(Z64->Z64_SENHA) .And. AllTrim(Z64->Z64_SENHA) <> "123") .Or.;
	      (AllTrim(_cSenha) <> "123" .And. ::lSetNewPsw) )	
	 	
		::cEmpSel := SubStr(Z64->Z64_EMPFIL,1,2)  //empresa do usuario
		
		_cUserERP := Z64->Z64_USUERP	
		
		cTemp := Alltrim(Z64->Z64_ACESSO)
		cTemp := StrTran(cTemp,":","|")
		cTemp := StrTran(cTemp,";","|")
		cTemp := StrTran(cTemp,",","|")
		cTemp := StrTran(cTemp,"/","|")
		cTemp := StrTran(cTemp,"\","|")
		cTemp := StrTran(cTemp,"-","|")
		cTemp := StrTran(cTemp,"_","|")
		if !("|" $ cTemp)
			cTemp += "|"
		endif
		::aAcessos := StrTokArr( cTemp, "|" )
			
		PswOrder(2)	
		If !PswSeek( _cUserERP, .T. )
		
			::DlgMensagem("Usuário inválido no ERP!","ACESSO AO SISTEMA","ALERT")
			lVldSenha := .F.
			
		Else
		
			::cUsuERP := _cUserERP
			
			If (::lSetNewPsw)
			
				RecLock("Z64",.F.)
				Z64->Z64_SENHA := Alltrim(_cSenha)
				Z64->(MsUnlock())
				
				::lSetNewPsw := .F.
				
			EndIf				
			
		EndIf
		
	ElseIf Z64->(DbSeek(XFilial("Z64")+_cUsuario)) .And. AllTrim(Z64->Z64_SENHA) == "123"
	 
		::lSetNewPsw := .T.
		
		::DlgMensagem("NOVO USUÁRIO: Favor acessar novamente e digitar a NOVA SENHA desejada.","ACESSO AO SISTEMA","ALERT")
		lVldSenha := .F.
		
	Else
	
		::DlgMensagem("Usuário/Senha para Coletor inválido!","ACESSO AO SISTEMA","ALERT")
		lVldSenha := .F.
	
	EndIf
	
Return lVldSenha


//Carregar vetor do menu principal
Method LoadMenu() Class TBiaAutoColetor
                  	
local nc := 0
                  	
::aMenu := {}

DbSelectArea('Z86')
Z86->(DbSetOrder(1))

for nc:=1 to len(::aAcessos)
	if Z86->(DbSeek(xFilial('Z86')+::aAcessos[nc]))
		if Z86->Z86_MSBLQL <> '1'
			aAdd(::aMenu, {"S",Alltrim(Z86->Z86_DESCR), Z86->Z86_OPCAO, 1})
		endif	
	endif
next nc	
Return          


//Tela de selecao do menu principal
Method DlgMenu() Class TBiaAutoColetor
 
Local oDlgMenu  
Local oList     
Local nList
Local aItens	:= {} 
Local cTitulo	:= "Seleciona a opção:"

AEval(::aMenu, {|x| aAdd(aItens, x[2] ) })

//Janela
oDlgMenu := TDialog():New(0, 0, 0, 0)
oDlgMenu:nWidth		:= ::nSrcWidth
oDlgMenu:nHeight	:= ::nSrcHeight
oDlgMenu:cCaption 	:= cTitulo
oDlgMenu:nStyle 	:= DS_MODALFRAME
oDlgMenu:lEscClose	:= .T.     

oList := TListBox():Create(oDlgMenu,001,001,{|u|if(Pcount()>0,nList:=u,nList)},aItens,125,105,,,,,.T.)
oList:oFont := ::oBold12

oConfirma := TBUTTON():Create(oDlgMenu)
oConfirma:cCaption	:= "Confirmar"
oConfirma:nLeft 	:= 40
oConfirma:nTop 		:= 220
oConfirma:nWidth 	:= 60
oConfirma:nHeight 	:= 24
oConfirma:bAction := {|| IIF( oList:nAt > 0 , ::MenuActivate(oList:nAt),  ) }   

oCancela := TBUTTON():Create(oDlgMenu)
oCancela:cCaption	:= "Cancelar"
oCancela:nLeft 		:= 140
oCancela:nTop 		:= 220
oCancela:nWidth 	:= 60
oCancela:nHeight 	:= 24
oCancela:bAction	:= {|| oDlgMenu:End() } 
          
oList:nAt := 1  
oConfirma:SetFocus()
oDlgMenu:Activate(,,,.T. /*lCentered*/)

::Start()

Return
    

//Tela de selecao do menu principal
Method MenuActivate(nPos) Class TBiaAutoColetor
        
local oProc	:= nil
local cTemp	:= ''

DbSelectArea('Z86')
Z86->(DbSetOrder(1))

if Z86->(DbSeek(xFilial('Z86')+::aMenu[nPos][3]))
	
	cTemp := 'oProc := '+Alltrim(Z86->Z86_CLASSE)+'():New(Self)'
	__runcb(__CompStr(cTemp),.F.)
	
	cTemp := 'oProc:'+Alltrim(Z86->Z86_PROGEX)+'()'
	__runcb(__CompStr(cTemp),.F.)
endif

Return


//User Function de Acesso do Coletor
User Function FCOLTE01

Local oColetor

oColetor := TBiaAutoColetor():New() 
oColetor:Start()

Return