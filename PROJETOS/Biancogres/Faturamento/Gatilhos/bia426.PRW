#include "rwmake.ch"
#include "topconn.ch"

User Function BIA426()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA426 	³ Autor ³ Wanisay William       ³ Data ³ 16/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o preenchimento do data de emissao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Estoque                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local cProduto := ''

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA240
IF Type("_IViaEAuto") <> "U"
	Return(M->D3_COD)
ENDIF

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
IF Type("_ExecAutoII") <> "U"
	cProduto := Gdfieldget("D3_COD",n)
	RETURN(cProduto)
ENDIF

//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
If Type("_ExcAut292") <> "U"
	cProduto := M->D3_COD
EndIf

//Todas as validacoes abaixo estao sendo realizadas em ponto de entrada com excecao da funcao BIANCO1
DO CASE
	CASE Alltrim(funname())=="MATA261"     //Transferencia de Estoque Mod(2).
		IF DA261DATA <> DDATABASE
			aCols[n,1] := SPACE(15)
		ELSE
			cProduto   := aCols[n,1]
		ENDIF
	CASE Alltrim(funname())$ "MATA242"     //Desmontagem de Produto - Transferência Multipla - Foi necessário retirar esta rotina diretamente na tabela de gatilhos porque o retorno preenche o cabec da rotina dando erro.
		IF DEMIS260 <> DDATABASE
			aCols[n,1] := SPACE(15)
		ELSE
			cProduto   := aCols[n,1]
		ENDIF
	CASE Alltrim(funname())$ "MATA241"     //Movimentos Internos Mod(2)/Pre-Requisicao
		IF DA241DATA <> DDATABASE
			aCols[n,1] := SPACE(15)
		ELSE
			cProduto   := aCols[n,1]
		ENDIF
	CASE Alltrim(funname())=="MATA240" .OR. Alltrim(funname())=="MATA250" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"    //Movimentos Internos Mod(1) ou Producao.
		IF M->D3_EMISSAO <> DDATABASE
			M->D3_COD := SPACE(15)
		ELSE
			cProduto   := M->D3_COD
		ENDIF
	CASE Alltrim(funname())=="BIANCO1"     //Transferencia de Empenho.
		IF M->ZF_EMISSAO <> DDATABASE
			aCols[n,2] := SPACE(15)
		ELSE
			cProduto   := aCols[n,2]
		ENDIF
	CASE Upper(Alltrim(funname())) $ "BIA257/BIA802/BIA271/MATA240/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")  // Incluida regra por Marcos Alberto em 24/08/11 para atender as exigências do apontamento automático do Esmalte
		cProduto := M->D3_COD
		Return(cProduto)
ENDCASE

IF SUBSTR(cProduto,1,1) == ' '
	MsgBox("Favor informar data correta","BIA426","STOP")
ENDIF

Return(cProduto)
