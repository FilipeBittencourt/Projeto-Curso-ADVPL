#include "totvs.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "vkey.ch"
#define DS_MODALFRAME 128

/*/{Protheus.doc} TBiaAutoBordero
@author Artur Antunes
@since 26/04/2017
@version 1.0
@description Classe para manutenção de Borderô via coletor (Telas)
@obs OS 0104-17
@type class
/*/

Class TBiaAutoBordero From LongClassName

	Data oColetor   
	Data oBordero
	Data oDlgBord 
	Data oGetProd
	Data oGetLote
	Data oGetEtiq
	     
	Data cGetEtiq
	Data cGetProd
	Data cGetlote  
	Data lLoadOk 
	
	Method New(oColetor) Constructor 
	Method DlgBordero()
	Method LoadEtiqueta() 
	Method ProcBordero()

EndClass

                      
//Construtor da Classe
Method New(oColetor) Class TBiaAutoBordero
	::oColetor := oColetor
	::oBordero := TBiaBordero():New(oColetor)
	::oDlgBord := nil
	::oGetProd := nil
	::oGetLote := nil
	::oGetEtiq := nil
	::cGetEtiq := ''
	::cGetProd := ''
	::cGetlote := ''  
	::lLoadOk  := .F.
Return


//Tela de selecao da etiqueta
Method DlgBordero() Class TBiaAutoBordero

Local cTitulo	:= "Manutenção de Borderô"

::cGetEtiq	:= Space(20)
::cGetProd	:= Space(15)
::cGetlote 	:= Space(10)

//Janela
::oDlgBord := TDialog():New(0, 0, 0, 0)
::oDlgBord:nWidth		:= ::oColetor:nSrcWidth
::oDlgBord:nHeight		:= ::oColetor:nSrcHeight
::oDlgBord:cCaption 	:= cTitulo
::oDlgBord:nStyle 		:= DS_MODALFRAME
::oDlgBord:lEscClose	:= .T.

oLblBor	:= TSay():Create(::oDlgBord)
oLblBor:nLeft 		:= 10
oLblBor:nTop 		:= 20
oLblBor:nWidth 		:= 210
oLblBor:nHeight 	:= 30
oLblBor:nClrText 	:= CLR_BLUE
oLblBor:oFont 		:= ::oColetor:oBold11
oLblBor:SetText("Ler/Digitar Etiqueta:")
		  
::oGetEtiq	:= TGet():Create(::oDlgBord)
::oGetEtiq:bSetGet 	:=  {|u| If(PCount() > 0, ::cGetEtiq := u, ::cGetEtiq) }
::oGetEtiq:nLeft 	:= 10
::oGetEtiq:nTop 	:= 45
::oGetEtiq:nWidth 	:= 240
::oGetEtiq:nHeight 	:= 30
::oGetEtiq:nClrText := CLR_RED
::oGetEtiq:bWhen 	:= {|| .T. }
::oGetEtiq:bChange 	:= {|| ::LoadEtiqueta()  }
::oGetEtiq:oFont 	:= ::oColetor:oBold16
::oGetEtiq:Picture	:= "@E 99999999999999999999" 

oLbl1	:= TSay():Create(::oDlgBord)
oLbl1:nLeft 		:= 10
oLbl1:nTop 			:= 80
oLbl1:nWidth 		:= 210
oLbl1:nHeight 		:= 30
oLbl1:nClrText 		:= CLR_BLUE
oLbl1:oFont 		:= ::oColetor:oBold11
oLbl1:SetText("Produto:")
		  
::oGetProd	:= TGet():Create(::oDlgBord)
::oGetProd:bSetGet 		:=  {|u| If(PCount() > 0, ::cGetProd := u, ::cGetProd) }
::oGetProd:nLeft 		:= 60
::oGetProd:nTop 		:= 80
::oGetProd:nWidth 		:= 190
::oGetProd:nHeight 		:= 20
::oGetProd:nClrText 	:= CLR_RED
::oGetProd:bWhen 		:= {|| .F. }
::oGetProd:oFont 		:= ::oColetor:oBold11
::oGetProd:Picture		:= "@!"	 

oLbl2	:= TSay():Create(::oDlgBord)
oLbl2:nLeft 		:= 10
oLbl2:nTop 			:= 120
oLbl2:nWidth 		:= 210
oLbl2:nHeight 		:= 30
oLbl2:nClrText 		:= CLR_BLUE
oLbl2:oFont 		:= ::oColetor:oBold11
oLbl2:SetText("Lote:")
		  
::oGetLote	:= TGet():Create(::oDlgBord)
::oGetLote:bSetGet 		:=  {|u| If(PCount() > 0, ::cGetlote := u, ::cGetlote) }
::oGetLote:nLeft 		:= 60
::oGetLote:nTop 		:= 120
::oGetLote:nWidth 		:= 190
::oGetLote:nHeight 		:= 20
::oGetLote:nClrText 	:= CLR_RED
::oGetLote:bWhen 		:= {|| .F. }
::oGetLote:oFont 		:= ::oColetor:oBold11
::oGetLote:Picture		:= "@!"	 

oConfirma := TBUTTON():Create(::oDlgBord)
oConfirma:cCaption	:= "Confirmar"
oConfirma:nLeft 	:= 40
oConfirma:nTop 		:= 220
oConfirma:nWidth 	:= 60
oConfirma:nHeight 	:= 24  
oConfirma:bWhen		:= {|| ::lLoadOk }
oConfirma:bGotFocus := {|| IIf(!::lLoadOk, ::oGetEtiq:SetFocus(), ) }
oConfirma:bAction 	:= {|| IIf(::lLoadOk, ::ProcBordero(),::oGetEtiq:SetFocus() ) }   

oCancela := TBUTTON():Create(::oDlgBord)
oCancela:cCaption	:= "Cancelar"
oCancela:nLeft 		:= 140
oCancela:nTop 		:= 220
oCancela:nWidth 	:= 60
oCancela:nHeight 	:= 24
oCancela:bAction	:= {|| ::oDlgBord:End() }                         
//oCancela:bGotFocus  := {|| IIf(!::lLoadOk, ::oGetEtiq:SetFocus(), ) }
          
::oDlgBord:Activate(,,,.T.)

Return
                

//Metodo de carregar os dados da etiqueta
Method LoadEtiqueta() Class TBiaAutoBordero
local lContinua := .T.

If !Empty(::cGetEtiq)

	if lContinua
		if ::oBordero:ExistEtiqProc(::cGetEtiq)

			::lLoadOk := .F.
			
			::oColetor:DlgMensagem("Etiqueta já processada.","Carregar Etiqueta","ALERT")
			
			::cGetEtiq := Space(20)
			::cGetProd := space(15)
			::cGetlote := space(10)
					
			::oDlgBord:Refresh()
			::oGetEtiq:SetFocus()
		
			lContinua := .F.		
		endif
	endif

	if lContinua
		If ::oBordero:LoadEtiq(::cGetEtiq)
		    
			::lLoadOk := .T.
			
			::cGetProd := ::oBordero:cProduto
			::cGetlote := ::oBordero:cLote
			
			::oDlgBord:Refresh()
			
		Else                
		
			::lLoadOk := .F.
			
			::oColetor:DlgMensagem("Etiqueta não encontrada ou não está aberta.","Carregar Etiqueta","ALERT")
			
			::cGetEtiq := Space(20)
			::cGetProd := space(15)
			::cGetlote := space(10)
					
			::oDlgBord:Refresh()
			::oGetEtiq:SetFocus()
		
			lContinua := .F.
		EndIf
	endif
EndIf
Return


//Processar Borderô
Method ProcBordero() Class TBiaAutoBordero

Local oDlgProgresso := nil
Local aRet			:= {}      
Local oBordero 		:= ::oBordero
Local cUsuERP  		:= ::oColetor:cUsuERP
	
Define	MsDialog oDlgProgresso;
				Title "Aguarde...";
				From 100,100; 
		  		To 140,300; 
		  		Pixel; 
		    	Style DS_MODALFRAME

@ 006,005 Say "Realizando Manutenção... ";
			 Size 100,012;
			 Color CLR_BLUE;
			 Pixel Of oDlgProgresso;
			 Font ::oColetor:oBold11

Activate MsDialog oDlgProgresso Centered On Init ( aRet := oBordero:UpdBordero(cUsuERP), oDlgProgresso:End() )
	
If !( aRet[1] )
	::oColetor:DlgMensagem(aRet[2],"Manutenção de Borderô","ALERT")
Else                                                            
	::oColetor:DlgMensagem("Manutenção de Borderô realizada com sucesso!","Manutenção de Borderô","ALERT")
		
	::cGetEtiq	:= Space(20)
	::cGetProd	:= Space(15)
	::cGetlote 	:= Space(10)
	::oBordero  := TBiaBordero():New(::oColetor)
	::lLoadOk   := .F.
	::oGetEtiq:SetFocus()	
EndIf

Return( aRet[1] )
