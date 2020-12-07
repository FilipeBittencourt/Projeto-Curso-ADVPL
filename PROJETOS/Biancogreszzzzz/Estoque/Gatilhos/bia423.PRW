#include "rwmake.ch"
#include "topconn.ch"

User Function BIA423()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA423 	³ Autor ³ Wanisay William       ³ Data ³ 15/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o preenchimento do campo de Lote e Produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Estoque                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private lRet     := .F.
Private cProduto
Private cLote

cLote := ""

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO
IF Type("_IViaEAuto") <> "U"
	Return(M->D3_LOTECTL)
ENDIF

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
IF Type("_ExecAutoII") <> "U"
	cLote := Gdfieldget("D3_LOTECTL",n)
	RETURN(cLote)
ENDIF

//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
If Type("_ExcAut292") <> "U"
	cLote := M->D3_LOTECTL
	Return(cLote)
EndIf
//Faturamento Intra-Grupo
If IsInCallStack("fIntraOP")
	cLote := M->D3_LOTECTL
	Return(cLote)
EndIf

DO CASE
	CASE Alltrim(funname())=="MATA261"     //Transferencia de Estoque Mod(2).
		//cProduto    := aCols[n,6]
		//cLote       := aCols[n,20]
		//aCols[n,20] := aCols[n,12]
		//IF DA261DATA <> DDATABASE
		//   aCols[n,1] := SPACE(15)
		//ENDIF
		
	CASE Alltrim(funname())=="MATA241"     //Movimentos Internos Mod(2).
		cProduto := Gdfieldget("D3_COD",n) 			//aCols[n,1]
		cLote    := Gdfieldget("D3_LOTECTL",n) //aCols[n,6]
		IF DA241DATA <> DDATABASE
			aCols[n,1] := SPACE(15)
		ENDIF
		
	CASE Alltrim(funname())=="MATA240" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"    //Movimentos Internos Mod(1) ou Producao.
		cProduto := M->D3_COD
		cLote    := M->D3_LOTECTL
		IF M->D3_EMISSAO <> DDATABASE
			M->D3_COD := SPACE(15)
		ENDIF
		
	CASE Alltrim(funname())=="BIANCO1"     //Transferencia de Empenho.
		cProduto := aCols[n,2]
		cLote    := aCols[n,10]
		IF M->ZF_EMISSAO <> DDATABASE
			aCols[n,2] := SPACE(15)
		ENDIF
		
	CASE Alltrim(funname())=="MATA410"     	//Pedido de Venda.
		cProduto := Gdfieldget("C6_PRODUTO",n)	//aCols[n,2]
		cLote    := Gdfieldget("C6_LOTECTL",n)	//aCols[n,38]
		
	CASE Alltrim(funname())=="MATA103"     	//Nota Fiscal de Entrada
		cProduto := Gdfieldget("D1_COD",n)			//aCols[n,1]
		cLote    := Gdfieldget("D1_LOTECTL",n)	//aCols[n,42]
		
	CASE Upper(Alltrim(FunName())) $ "BIA257/BIA271/MATA250/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")   	//Apontamento Automático de Produção implementado em 28/11/11 por Marcos Alberto Soprani
		cProduto := M->D3_COD
		cLote    := M->D3_LOTECTL
		If cEmpAnt <> "14"  // Implementado em 21/01/14 por Marcos Alberto Soprani para atender a entrada em produção da Vitcer
			Return(cLote)
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cProduto))
			If SB1->B1_RASTRO == "N"
				Return(cLote)
			EndIf
		EndIf
		
	CASE Alltrim(funname()) == "MATA242"      // Implementado em 07/01/14 Por Marcos Alberto Soprani para resolver problema de cadastro de produto e importação de produção errados
		cProduto := Gdfieldget("D3_COD",n)
		cLote    := Gdfieldget("D3_LOTECTL",n)
		
	OTHERWISE
		cProduto := SPACE(15)
		cLote    := SPACE(10)
		
ENDCASE

dbSelectArea("ZZ9")
dbSetOrder(1)
dbGoTop()
If dbSeek(xFilial("ZZ9")+cLote+cProduto)
	lRet  := .T.
Else
	MsgSTOP("Este Lote: "+ALLTRIM(cLote)+" nao esta amarrado ao Produto: "+ALLTRIM(cProduto),"BIA423","STOP")
	cLote := Space(10)
EndIf

Return(cLote)
