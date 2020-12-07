#include "rwmake.ch"
#include "topconn.ch"
/*/{Protheus.doc} BIAFG111
@author Gabriel Rossi Mafioletti
@since 16/10/2019
@version 1.0
@description Validação do campo D1_YTESPN
@type function
/*/

User Function BIAFG111()

	Local _aArea	:=	GetArea()

	Local nPosClVl	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CLVL"})
	Local nPosCod	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
	Local nPosLocal	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_LOCAL"})
	Local nPosRegra	  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_YREGRA"})


	Local cClVl		:=	aCols[n,nPosClvl]
	Local cCodPro	:=	aCols[n,nPosCod]
	Local cRegra	:=	aCols[n,nPosRegra]
	Local cLocal	:=	aCols[n,nPosLocal]

	Local cArqSF4	:= ""
	Local cIndSF4	:= 0
	Local cRegSF4	:= 0

	local cArqSB1	:= ""
	local cIndSB1	:= 0
	local cRegSB1	:= 0

	local cArqSBM	:= ""
	local cIndSBM	:= 0
	local cRegSBM	:= 0
	Local lRetorno	:=	.T.

	DbSelectArea("SF4")
	cArqSF4 := Alias()
	cIndSF4 := IndexOrd()
	cRegSF4 := Recno()
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+M->D1_YTESPN))

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCodPro,.F.)

	DbSelectArea("SBM")
	cArqSBM := Alias()
	cIndSBM := IndexOrd()
	cRegSBM := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SBM")+SB1->B1_GRUPO,.F.)

	DbSelectArea("ZCN")
	DbSetOrder(2)
	DbSeek(xFilial("ZCN")+cCodPro+cLocal,.T.)


	IF Subs(cCLVL,1,1) = "8" .AND. Alltrim(SF4->F4_ESTOQUE) == "S"
		MsgAlert("TES - PN Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!","Atencao","ALERT")
		
		lRetorno := .F.
	ELSE
		//Verifica se o Produto e do Tipo MD
		IF cREGRA = "N"
			If Alltrim(ZCN->ZCN_MD) == "S"
				IF SBM->BM_YCON_MD = "N"
					//Para Produto MD so pode utilizar TES que nao atualiza Estoque
					If Alltrim(SF4->F4_ESTOQUE) == "S"
						MsgBox("TES - PN Usada Invalida - Este material e do tipo MD e nao devera atualizar estoque!","Atencao","ALERT")
						
						lRetorno := .F.
					EndIf
					//Verifica se a Classe de Valor esta em branco
					If Empty(cCLVL)
						MsgBox("Classe de Valor em branco para produto MD, favor preencher a mesma para continuar!","Atencao","ALERT")
						
						lRetorno := .F.
					EndIf
				ELSE
					If cempant == "01"
						If Alltrim(SF4->F4_ESTOQUE) == "N"
							MsgBox("TES - PN Usada Invalida - Este material e do tipo MD e devera atualizar estoque!","Atencao","ALERT")
							
							lRetorno := .F.
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	If cArqSF4 <> ""
		dbSelectArea(cArqSF4)
		dbSetOrder(cIndSF4)
		dbGoTo(cRegSF4)
		RetIndex("SF4")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSBM <> ""
		dbSelectArea(cArqSBM)
		dbSetOrder(cIndSBM)
		dbGoTo(cRegSBM)
		RetIndex("SBM")
	EndIf


Return lRetorno