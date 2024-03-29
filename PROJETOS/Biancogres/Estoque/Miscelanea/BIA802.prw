#include "rwmake.ch"
#include "topconn.ch"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA802     � Autor � Ranisses A. Corona    � Data � 29/07/08 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Calcula o saldo do produto, usando o valor da funcao CALCEST 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Movimentacao Interna Mod II                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

User Function BIA802()

	Private nQuant := 0

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO
	IF Type("_IViaEAuto") <> "U"
		Return(M->D3_QUANT)
	ENDIF

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	IF Type("_ExecAutoII") <> "U"
		nQuant := Gdfieldget("D3_QUANT",n)
		RETURN(nQuant)
	ENDIF

	IF IsInCallStack("MATA250") //Alltrim(funname())=="MATA250"
		Return(M->D3_QUANT)
	ENDIF

	//Por Marcos Alberto Soprani em 25/05/12 para atender a integra玢o com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		Return(M->D3_QUANT)
	EndIf

	// Incluida regra por Marcos Alberto em 24/08/11 para atender o apontamento autom醫ico de Esmalte
	If Upper(Alltrim(funname())) $ "BIA257/BIA802/BIA271/MATA240/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")
		Return(M->D3_QUANT)
	EndIf

	//Busca variaveis no acols
	nPosProd	:= aScan(aHeader,{|x| Alltrim(x[2])=="D3_COD"})
	nPosAlmx	:= aScan(aHeader,{|x| Alltrim(x[2])=="D3_LOCAL"})
	nPosQuant	:= aScan(aHeader,{|x| Alltrim(x[2])=="D3_QUANT"})

	nProduto	:= Alltrim(Acols[n,nPosProd])
	nAlmx		:= Alltrim(Acols[n,nPosAlmx])
	nQuant		:= Acols[n,nPosQuant]

	//Executa apenas na rotina de Movimentacao Interna Mod. II
	If IsInCallStack("MATA241") //Upper(Alltrim(FUNNAME())) == "MATA241"

		//Realiza a verificacao do estoque, apenas para requisicoes/saidas
		If Alltrim(CTM) > '500'

			//Executa Funcao CalcEst
			aSaldos := CalcEst(nProduto,nAlmx,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente

			//Verifica se existe saldo suficiente para baixa da requisicao
			If aSaldos[1] < nQuant
				MsgAlert("Nao existe saldo suficiente, para atender esta Requisicao! Favor conferir o Saldo em Estoque!", "BIA802!!!")
				Acols[n,nPosQuant] 	:= 0.00
				nQuant			    := 0.00
			EndIf

		EndIf

	EndIf

Return(nQuant)
