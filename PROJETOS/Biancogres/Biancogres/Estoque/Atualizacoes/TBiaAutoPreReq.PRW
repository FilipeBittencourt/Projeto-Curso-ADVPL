*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#include "totvs.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "vkey.ch"
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#define DS_MODALFRAME 128
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function FCLA0015; Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TBiaAutoColetor	∫Autor  ≥Fernando Rocha      ∫ Data ≥ 09/09/2015  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Classe para telas do Coletor de dados da baixa de Pre Requisicao	  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ BIANCOGRES 												  	      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Class TBiaAutoPreReq From LongClassName

Data oColetor   
Data oPreReq

Data oDlgReq
Data oGetReq      
Data cGetReq
Data oGetNome
Data cGetNome
Data oGetData
Data cGetData
Data oGetCLVL
Data cGetCLVL

Data oDlgGetProd
Data oGetProd
Data cGetProd  
Data oGetQuant
Data nGetQuant
Data oListProd 
Data aProdutos

Data lLoadOk 
Data lConfOk

Method New(oColetor) Constructor 

Method DlgBxReq()
Method LoadReq() 
Method DlgGetProd()
Method UpdListProd()  
Method AltQtde()  
Method ProcBaixa()

EndClass
                      
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Construtor da Classe
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ      
Method New(oColetor) Class TBiaAutoPreReq

::oColetor := oColetor
::oPreReq := TBiaPreRequisicao():New(oColetor)
::lLoadOk := .F.
::lConfOk := .F.

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Tela de selecao da requisicao para baixar
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method DlgBxReq() Class TBiaAutoPreReq

Local oLblReq      
Local oLbl1
Local cTitulo	:= "Baixar PrÈ-RequisiÁ„o"

::cGetReq	:= Space(9)
::cGetNome	:= Space(30)
::cGetData 	:= Space(10)
::cGetCLVL	:= Space(4)

//Janela
::oDlgReq := TDialog():New(0, 0, 0, 0)
::oDlgReq:nWidth		:= ::oColetor:nSrcWidth
::oDlgReq:nHeight		:= ::oColetor:nSrcHeight
::oDlgReq:cCaption 		:= cTitulo
::oDlgReq:nStyle 		:= DS_MODALFRAME
::oDlgReq:lEscClose		:= .T.

oLblReq	:= TSay():Create(::oDlgReq)
oLblReq:nLeft 		:= 10
oLblReq:nTop 		:= 20
oLblReq:nWidth 		:= 210
oLblReq:nHeight 	:= 30
oLblReq:nClrText 	:= CLR_BLUE
oLblReq:oFont 		:= ::oColetor:oBold11
oLblReq:SetText("Ler/Digitar PrÈ-RequisiÁ„o:")
		  
::oGetReq	:= TGet():Create(::oDlgReq)
::oGetReq:bSetGet 	:=  {|u| If(PCount() > 0, ::cGetReq := u, ::cGetReq) }
::oGetReq:nLeft 	:= 10
::oGetReq:nTop 		:= 45
::oGetReq:nWidth 	:= 240
::oGetReq:nHeight 	:= 30
::oGetReq:nClrText 	:= CLR_RED
::oGetReq:bWhen 	:= {|| .T. }
::oGetReq:bChange 	:= {|| ::LoadReq()  }
::oGetReq:oFont 	:= ::oColetor:oBold16
::oGetReq:Picture	:= "@!" 

oLbl1	:= TSay():Create(::oDlgReq)
oLbl1:nLeft 		:= 10
oLbl1:nTop 			:= 80
oLbl1:nWidth 		:= 210
oLbl1:nHeight 		:= 30
oLbl1:nClrText 		:= CLR_BLUE
oLbl1:oFont 		:= ::oColetor:oBold11
oLbl1:SetText("Nome:")
		  
::oGetNome	:= TGet():Create(::oDlgReq)
::oGetNome:bSetGet 		:=  {|u| If(PCount() > 0, ::cGetNome := u, ::cGetNome) }
::oGetNome:nLeft 		:= 60
::oGetNome:nTop 		:= 80
::oGetNome:nWidth 		:= 190
::oGetNome:nHeight 		:= 20
::oGetNome:nClrText 	:= CLR_RED
::oGetNome:bWhen 		:= {|| .F. }
::oGetNome:oFont 		:= ::oColetor:oBold11
::oGetNome:Picture		:= "@!"	 

oLbl2	:= TSay():Create(::oDlgReq)
oLbl2:nLeft 		:= 10
oLbl2:nTop 			:= 120
oLbl2:nWidth 		:= 210
oLbl2:nHeight 		:= 30
oLbl2:nClrText 		:= CLR_BLUE
oLbl2:oFont 		:= ::oColetor:oBold11
oLbl2:SetText("Data:")
		  
::oGetData	:= TGet():Create(::oDlgReq)
::oGetData:bSetGet 		:=  {|u| If(PCount() > 0, ::cGetData := u, ::cGetData) }
::oGetData:nLeft 		:= 60
::oGetData:nTop 		:= 120
::oGetData:nWidth 		:= 190
::oGetData:nHeight 		:= 20
::oGetData:nClrText 	:= CLR_RED
::oGetData:bWhen 		:= {|| .F. }
::oGetData:oFont 		:= ::oColetor:oBold11
::oGetData:Picture		:= "@!"	 

oLbl3	:= TSay():Create(::oDlgReq)
oLbl3:nLeft 		:= 10
oLbl3:nTop 			:= 160
oLbl3:nWidth 		:= 210
oLbl3:nHeight 		:= 30
oLbl3:nClrText 		:= CLR_BLUE
oLbl3:oFont 		:= ::oColetor:oBold11
oLbl3:SetText("Classe:")
		  
::oGetCLVL	:= TGet():Create(::oDlgReq)
::oGetCLVL:bSetGet 		:=  {|u| If(PCount() > 0, ::cGetCLVL := u, ::cGetCLVL) }
::oGetCLVL:nLeft 		:= 60
::oGetCLVL:nTop 		:= 160
::oGetCLVL:nWidth 		:= 190
::oGetCLVL:nHeight 		:= 20
::oGetCLVL:nClrText 	:= CLR_RED
::oGetCLVL:bWhen 		:= {|| .F. }
::oGetCLVL:oFont 		:= ::oColetor:oBold11
::oGetCLVL:Picture		:= "@!"	    

oConfirma := TBUTTON():Create(::oDlgReq)
oConfirma:cCaption	:= "Baixar"
oConfirma:nLeft 	:= 40
oConfirma:nTop 		:= 220
oConfirma:nWidth 	:= 60
oConfirma:nHeight 	:= 24  
oConfirma:bWhen		:= {|| ::lLoadOk }
oConfirma:bGotFocus := {|| IIf(!::lLoadOk, ::oGetReq:SetFocus(), ) }
oConfirma:bAction 	:= {|| IIf(::lLoadOk, ::DlgGetProd(), ) }   

oCancela := TBUTTON():Create(::oDlgReq)
oCancela:cCaption	:= "Cancelar"
oCancela:nLeft 		:= 140
oCancela:nTop 		:= 220
oCancela:nWidth 	:= 60
oCancela:nHeight 	:= 24
oCancela:bAction	:= {|| ::oDlgReq:End() }                         
oCancela:bGotFocus := {|| IIf(!::lLoadOk, ::oGetReq:SetFocus(), ) }
          
::oDlgReq:Activate(,,,.T. /*lCentered*/)

Return
                
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Metodo de carregar os dados da requisicao a ser baixada
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method LoadReq() Class TBiaAutoPreReq

If !Empty(::cGetReq)

	If ::oPreReq:LoadReq(::cGetReq)
	    
		::lLoadOk := .T.
		
		::cGetNome := ::oPreReq:cNome
		::cGetData := DTOC(::oPreReq:dEmissao)
		::cGetCLVL := ::oPreReq:cCLVL
		
		::oDlgReq:Refresh()
		
	Else                
	
		::lLoadOk := .F.
		
		::oColetor:DlgMensagem("RequisiÁ„o n„o encontrada ou n„o est· aberta.","CARREGAR REQUISI«√O","ALERT")
		
		::cGetReq	:= Space(9)
		::cGetNome	:= Space(30)
		::cGetData 	:= Space(10)
		::cGetCLVL	:= Space(4)
		
		::oDlgReq:Refresh()
	
	EndIf

EndIf

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Tela de digitacao dos itens
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method DlgGetProd() Class TBiaAutoPreReq

Local oLblProd 
Local oLblQtde
Local oLbl1
Local cTitulo	:= "Baixar PrÈ-RequisiÁ„o"

::cGetProd	:= Space(15)
::nGetQuant := 1   

::aProdutos := {}

//Janela
::oDlgGetProd := TDialog():New(0, 0, 0, 0)
::oDlgGetProd:nWidth		:= ::oColetor:nSrcWidth
::oDlgGetProd:nHeight		:= ::oColetor:nSrcHeight
::oDlgGetProd:cCaption 		:= cTitulo
::oDlgGetProd:nStyle 		:= DS_MODALFRAME
::oDlgGetProd:lEscClose		:= .F.

oLblProd	:= TSay():Create(::oDlgGetProd)
oLblProd:nLeft 		:= 10
oLblProd:nTop 		:= 20
oLblProd:nWidth 	:= 210
oLblProd:nHeight 	:= 30
oLblProd:nClrText 	:= CLR_BLUE
oLblProd:oFont 		:= ::oColetor:oBold11
oLblProd:SetText("Ler Produto:") 

oLblQtde	:= TSay():Create(::oDlgGetProd)
oLblQtde:nLeft 		:= 140
oLblQtde:nTop 		:= 20
oLblQtde:nWidth 	:= 50
oLblQtde:nHeight 	:= 30
oLblQtde:nClrText 	:= CLR_BLUE
oLblQtde:oFont 		:= ::oColetor:oBold11
oLblQtde:SetText("Qtde:")

::oGetQuant	:= TGet():Create(::oDlgGetProd)
::oGetQuant:bSetGet 	:=  {|u| If(PCount() > 0, ::nGetQuant := u, ::nGetQuant) }
::oGetQuant:nLeft 	:= 140
::oGetQuant:nTop 	:= 45
::oGetQuant:nWidth 	:= 60
::oGetQuant:nHeight := 30
::oGetQuant:nClrText := CLR_RED
//::oGetQuant:bWhen 	:= {|| .F. }
::oGetQuant:bChange 	:= {|| ::oGetProd:SetFocus()  }
::oGetQuant:oFont 	:= ::oColetor:oBold12
::oGetQuant:Picture	:= "@E 9999.99" 
::oGetQuant:Disable()

::oGetProd	:= TGet():Create(::oDlgGetProd)
::oGetProd:bSetGet 	:=  {|u| If(PCount() > 0, ::cGetProd := u, ::cGetProd) }
::oGetProd:nLeft 	:= 10
::oGetProd:nTop 	:= 45
::oGetProd:nWidth 	:= 120
::oGetProd:nHeight 	:= 30
::oGetProd:nClrText := CLR_RED
::oGetProd:bWhen 	:= {|| .T. }
::oGetProd:bChange 	:= {|| ::UpdListProd(), ::oGetProd:SetFocus() }   
::oGetProd:bGotFocus := {|| ::oGetQuant:Disable() }
::oGetProd:oFont 	:= ::oColetor:oBold12
::oGetProd:Picture	:= "@!"  

@ 045, 003 LISTBOX ::oListProd Fields HEADER "PRODUTO","QTDE" SIZE 140, 060 OF ::oDlgGetProd PIXEL ColSizes 80,20
//::oListProd:Disable()
::oListProd:bGotFocus := {|| IIf(!::lConfOk, ::oGetProd:SetFocus(), oConfirma:SetFocus()  ) }
::UpdListProd()

oConfirma := TBUTTON():Create(::oDlgGetProd)
oConfirma:cCaption	:= "Confirmar"
oConfirma:nLeft 	:= 10
oConfirma:nTop 		:= 220
oConfirma:nWidth 	:= 60
oConfirma:nHeight 	:= 24  
//oConfirma:bWhen		:= {|| ::lConfOk }
oConfirma:bGotFocus := {|| IIf(!::lConfOk, ::oGetProd:SetFocus(), ) }
oConfirma:bAction 	:= {|| IIF(::lConfOk, IIF(::ProcBaixa(),::oDlgGetProd:End(),),  ) }   

oAltQtd := TBUTTON():Create(::oDlgGetProd)
oAltQtd:cCaption	:= "Alt.Qtde"
oAltQtd:nLeft 		:= 80
oAltQtd:nTop 		:= 220
oAltQtd:nWidth 		:= 60
oAltQtd:nHeight 	:= 24  
oAltQtd:bWhen		:= {|| ::lLoadOk }
//oAltQtd:bGotFocus := {|| IIf(!::lConfOk, ::oGetProd:SetFocus(), ) }
oAltQtd:bAction 	:= {|| ::AltQtde() } 

oCancela := TBUTTON():Create(::oDlgGetProd)
oCancela:cCaption	:= "Cancelar"
oCancela:nLeft 		:= 150
oCancela:nTop 		:= 220
oCancela:nWidth 	:= 60
oCancela:nHeight 	:= 24
oCancela:bAction	:= {|| ::oDlgGetProd:End() }                         
//oCancela:bGotFocus := {|| IIf(!::lLoadOk, ::oGetProd:SetFocus(), ) }
          
::oDlgGetProd:Activate(,,,.T. /*lCentered*/)

Return
          
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Tela de digitacao dos itens
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method UpdListProd() Class TBiaAutoPreReq
 
Local aRet 
Local I
                 
If !Empty(::cGetProd) .And. ( ::nGetQuant > 0 )
	aRet := ::oPreReq:AddProduto(::cGetProd, ::nGetQuant)  
	
	If ( aRet[1] ) 
	              
		::aProdutos := {}
		
		For I := 1 To len(::oPreReq:aProdutos)
		
			aAdd(::aProdutos, {SubStr(::oPreReq:aProdutos[I][2],1,20),::oPreReq:aProdutos[I][3]})     
		
		Next I
	      
	Else
		
		::oColetor:DlgMensagem(aRet[2],"ADICIONAR PRODUTO","ALERT")
		
	EndIf
EndIf     
                                   
//verificar se todos os itens da requesiÁ„o est„o ok para liberar de finalizar a baixa
::lConfOk := ::oPreReq:ChkConfOk()
                       
If Len(::aProdutos) <= 0

	aAdd(::aProdutos, {Space(30),0})

EndIf

If Len(::aProdutos) > 0
	::oListProd:SetArray(::aProdutos)
	::oListProd:bLine := {|| {;
	      ::aProdutos[::oListProd:nAt,1],;
	      ::aProdutos[::oListProd:nAt,2];
	    }}
	::oListProd:Refresh()
EndIf

::nGetQuant := 1
::oGetQuant:Refresh()

Return
                
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Tela de digitacao dos itens
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method AltQtde() Class TBiaAutoPreReq

::oGetQuant:Enable()
::oGetQuant:SetFocus()

Return    

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Processar baixa
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method ProcBaixa() Class TBiaAutoPreReq

	Local oDlgProgresso
	Local aRet      
	Local oPreReq := ::oPreReq
	Local cUsuERP := ::oColetor:cUsuERP
	
	Define	MsDialog oDlgProgresso;
				Title "Aguarde...";
		    	From 100,100; 
		  		To 140,300; 
		  		Pixel; 
		    	Style DS_MODALFRAME

	@ 006,005 Say "Baixando PrÈ-RequisiÁ„o... ";
			 Size 100,012;
			 Color CLR_BLUE;
			 Pixel Of oDlgProgresso;
			 Font ::oColetor:oBold11

	Activate MsDialog oDlgProgresso Centered On Init   ( aRet := oPreReq:BaixarReq(cUsuERP), oDlgProgresso:End() )
	
	If !( aRet[1] )
		::oColetor:DlgMensagem(aRet[2],"BAIXAR REQUISI«√O","ALERT")
	Else                                                            
		::oColetor:DlgMensagem("PrÈ RequisiÁ„o baixada com sucesso!","BAIXAR REQUISI«√O","ALERT")
		
		::cGetReq	:= Space(9)
		::cGetNome	:= Space(30)
		::cGetData 	:= Space(10)
		::cGetCLVL	:= Space(4) 
		::oPreReq := TBiaPreRequisicao():New(::oColetor)
		::lLoadOk := .F.
		::lConfOk := .F.
		::oGetReq:SetFocus()	
	EndIf

Return( aRet[1] )