#include "protheus.ch"
       
/*/{Protheus.doc} MA261CPO, MA261D3 e MA261IN
@author Fernando/Facile
@since 10/11/2015
@version 1.0
@description Pontos de entrada da rotina de transferencia modelo 2 (mata261)
@obs ESTES 3 PONTOS DE ENTRADA ABAIXO TEM QUE SER USADO EM CONJUNTO PARA CAMPOS DE USUARIO NA TRANSFERECIA MODELO 2 
@type function
/*/

/*/{Protheus.doc} MA261CPO e MA261D3
@author Artur Antunes
@since 17/02/2017
@version 1.1
@description Ajustes para manutenção do campo D3_YIDECO (ID de Integração Ecosis), rotina BIAF063
@obs OS 0243/16
@type function
/*/

/*/{Protheus.doc} MA261CPO e MA261D3
@author Artur Antunes
@since 07/04/2017
@version 1.2
@description Ajustes para manutenção do campo D3_YIDECO (ID de Integração Ecosis), rotina BIAF070
@obs OS 1215-17
@type function
/*/
  
//ADICIONAR CAMPOS NO AHEADER DA TELA DE TRANSFERENCIA MODELO 2
User Function MA261CPO()
Local aAreaX3 := SX3->(GetArea())

If AllTrim(FunName()) $ "MATA261"  
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek('D3_YQTDPC'))
		Aadd(aHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
	EndIf
	
	if !INCLUI
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek('D3_YIDECO'))
			Aadd(aHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		EndIf	
	endif
EndIf

if IsInCallStack('MSEXECAUTO') .and. IsInCallStack('FSTransfere')  
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek('D3_YIDECO'))
		Aadd(aHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
	EndIf
endif

RestArea(aAreaX3)      
Return Nil 
    

//SALVAR OS CAMPOS DE USUARIO APOS GRAVACAO DA TRANSFERENCIA
User Function MA261D3()

Local nPosAcols  := ParamIXB   //No. da linha do aCols que esta sendo processado
Local nPosYIDECO := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_YIDECO"})
Local nPosYQTDPC := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_YQTDPC"})
Local nD3YIDECO  := 0
Local nD3YQTDPC  := 0
Local nRecno     := SD3->(RECNO())
Local cChaveItem := SD3->D3_FILIAL + SD3->D3_DOC + SD3->D3_NUMSEQ  
Local dEmissao	 := SD3->D3_EMISSAO
Local cDataHora	:=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"

SD3->(DbSetOrder(8))
SD3->(DbGoTop())
If SD3->(DbSeek(cChaveItem))
	While !SD3->(Eof()) .And. cChaveItem == SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ)
		if SD3->D3_EMISSAO == dEmissao .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'RE4/DE4'
			SD3->(RecLock("SD3",.F.))
			SD3->D3_YDHMOV := cDataHora
			SD3->(MsUnlock())
		endif	
		SD3->(DbSkip())
	EndDo
EndIF

If AllTrim(FunName()) $ "MATA261" .and. nPosYQTDPC > 0 
	nD3YQTDPC  := aCols[nPosAcols][nPosYQTDPC]
	SD3->(DbSetOrder(8))
	SD3->(DbGoTop())
	If SD3->(DbSeek(cChaveItem))
		While !SD3->(Eof()) .And. cChaveItem == SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ)
			if SD3->D3_EMISSAO == dEmissao .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'RE4/DE4'
				SD3->(RecLock("SD3",.F.))
				SD3->D3_YQTDPC := nD3YQTDPC
				SD3->(MsUnlock())
			endif	
			SD3->(DbSkip())
		EndDo
	EndIf
	SD3->(DbSetOrder(1))
	SD3->(DbGoto(nRecno)) //Restaurar linha posicionada.
endif	

if IsInCallStack('MSEXECAUTO') .and. IsInCallStack('FSTransfere') .and. nPosYIDECO > 0
	nD3YIDECO  := aCols[nPosAcols][nPosYIDECO]
	SD3->(DbSetOrder(8))
	SD3->(DbGoTop())
	If SD3->(DbSeek(cChaveItem))
		While !SD3->(Eof()) .And. cChaveItem == SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ)
			if SD3->D3_EMISSAO == dEmissao .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'RE4/DE4'
				SD3->(RecLock("SD3",.F.))
				SD3->D3_YIDECO := nD3YIDECO
				SD3->(MsUnlock())
			endif	
			SD3->(DbSkip())
		EndDo
	EndIf
	SD3->(DbSetOrder(1))
	SD3->(DbGoto(nRecno)) //Restaurar linha posicionada.
endif
Return Nil


//TDN - Preenche valores de campos na tela de estorno // CARREGAR O ACOLS COM CAMPOS DE USUARIO NO VISUALIZAR
User Function MA261IN()

Local nPosYQTDPC := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_YQTDPC'})
Local nPosYIDECO := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_YIDECO'})
Local nPosNUMSEQ := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_NUMSEQ'})
local nx		 := 0
Local nRecno	 := SD3->(RECNO())
   
If !( AllTrim(FunName()) $ "MATA261" )
	Return Nil
EndIf

if (nPosYQTDPC > 0 .or. nPosYIDECO > 0) .And. !INCLUI
	SD3->(DbSetOrder(8))
	SD3->(DbGoTop())
	for nx := 1 to len(aCols)
		If SD3->(DbSeek(xFilial('SD3')+cDocumento+aCols[nx,nPosNUMSEQ]))
			While !SD3->(Eof()) .And. SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ) == xFilial('SD3')+cDocumento+aCols[nx,nPosNUMSEQ]
				if SD3->D3_EMISSAO == dA261Data .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF == 'DE4'
					if nPosYQTDPC > 0
						aCols[nx,nPosYQTDPC] := SD3->D3_YQTDPC
					endif
					if nPosYIDECO > 0 	
						aCols[nx,nPosYIDECO] := SD3->D3_YIDECO	
					endif			
				endif	
				SD3->(DbSkip())
			EndDo
		endif
	next nx 
endif
SD3->(DbSetOrder(1))
SD3->(DbGoto(nRecno)) //Restaurar linha posicionada.
Return Nil