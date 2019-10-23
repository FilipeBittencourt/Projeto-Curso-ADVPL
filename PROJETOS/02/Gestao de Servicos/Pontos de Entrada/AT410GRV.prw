#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
/*
##############################################################################################################
# PROGRAMA...: AT410GRV         
# AUTOR......: Gabriel Rossi Mafioletti (FACILE SISTEMAS)
# DATA.......: 02/04/2015                      
# DESCRICAO..: Ponto de Entrada no momento em que está gerando o pedido de venda referente à Ordem de Serviço
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function AT410GRV
Local aArea       := GetArea()
Local aAreaSB1    := SB1->(GetArea())
Local aParams     := PARAMIXB
Local nPosProduto := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRODUTO" })
Local nPosYRef    := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_YREF" })

	M->C5_YOBS := M->AB6_YOBS
	
	IF !Empty(M->AB6_YCLI)
		M->C5_CLIENTE	:=	M->AB6_YCLI
		M->C5_LOJACLI	:=	M->AB6_YLJCLI 
		M->C5_CLIENT	:=	M->AB6_YCLI
		M->C5_LOJAENT	:=	M->AB6_YLJCLI 
	EndIf
	AB8->(DbSetOrder(1))
	If AB8->(DbSeek(XFilial("AB8")+M->AB6_NUMOS))
		//Identifica se é produto do grupo SERVICOS
		If SubStr(AB8->AB8_CODPRO,1,1) $ AllTrim(GetNewPar("FA_GRPSER","5"))
			M->C5_YCATEGO := "2"
		Else
			M->C5_YCATEGO := "1"
		EndIf
	EndIf
	
	For nX := 1 To Len(aCols)
		If SB1->(DbSeek(xFilial("SB1") + aCols[nX, nPosProduto]))
			If !Empty(SB1->B1_YREF)
				aCols[nX, nPosYRef] := SB1->B1_YREF
			End If
		End If
	Next nX

	RestArea(aAreaSB1)
	RestArea(aArea)
Return
