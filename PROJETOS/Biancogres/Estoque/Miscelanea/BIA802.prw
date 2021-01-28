#include "rwmake.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA802     ³ Autor ³ Ranisses A. Corona    ³ Data ³ 29/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o saldo do produto, usando o valor da funcao CALCEST ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Movimentacao Interna Mod II                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

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

	//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		Return(M->D3_QUANT)
	EndIf

	// Incluida regra por Marcos Alberto em 24/08/11 para atender o apontamento automático de Esmalte
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
