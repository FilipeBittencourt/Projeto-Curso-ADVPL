#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"


/*/{Protheus.doc} F290FIL
@description Ponto de Entrada para filtrar titlos na geracao da Fatura
@author Rubens Junior (FACILE)
@since 22/10/2013
@type function
/*/

User Function F290FIL()

	Local cSQL  := ""
	Local __lOk := .T.

	Private oDlgMvAd
	Private oButton1
	Private oComboBox1
	Private nComboBox1 := "Não"
	Private oGet1
	Private cGet1 := dDataBase
	Private oGet2
	Private cGet2 := dDataBase
	Private oSay1
	Private oSay2
	Private oSay3
	Private fh_Esc := .F.

	If IsInCallStack("U_BAF042") .Or. IsInCallStack("U_BAF042FD")
		__lOk := .T.
	Else

		If (AllTrim(FunName()) == 'RPC') .Or. (Upper(AllTrim(FunName())) == 'WFPREPENV') .Or. (Upper(AllTrim(FunName())) == 'FINA373')
			Return cSQL
		EndIf

		DEFINE MSDIALOG oDlgMvAd TITLE "Parametros adicionais" FROM 000, 000  TO 125, 350 COLORS 0, 16777215 PIXEL

		@ 010, 009 SAY oSay1 PROMPT "Considerar Tipo NDF:" SIZE 056, 007 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 025, 009 SAY oSay2 PROMPT "De Vencimento Real:" SIZE 059, 007 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 040, 009 SAY oSay3 PROMPT "Ate Vencimento Real:" SIZE 053, 007 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 009, 071 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"Sim","Não"} SIZE 061, 010 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 025, 072 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 040, 072 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlgMvAd COLORS 0, 16777215 PIXEL
		@ 008, 138 BUTTON oButton1 PROMPT "Ok" SIZE 025, 042 OF oDlgMvAd ACTION (fh_Esc := .T., oDlgMvAd:End()) PIXEL

		ACTIVATE MSDIALOG oDlgMvAd VALID fh_Esc

		If nComboBox1 == "Não"

			//Acrescenta filtro SQL na selecao das Faturas

		/*	cSQL := "E2_TIPO <> 'NDF' "
			cSQL += ".and. DTOS(E2_VENCREA) >= '"+dtos(cGet1)+"' .AND. DTOS(E2_VENCREA) <= '"+dtos(cGet2)+"' "
		Else
			cSQL := ".T."
			cSQL := "DTOS(E2_VENCREA) >= '"+dtos(cGet1)+"' .AND. DTOS(E2_VENCREA) <= '"+dtos(cGet2)+"' " 
		*/
			cSQL := "E2_TIPO <> 'NDF' AND E2_VENCREA >= '"+dtos(cGet1)+"' AND E2_VENCREA <= '"+dtos(cGet2)+"' "+CRLF
		Else
			cSQL := "E2_VENCREA >= '"+dtos(cGet1)+"' AND E2_VENCREA <= '"+dtos(cGet2)+"' "+CRLF
		EndIf

		// Tiago Rossini Coradini - OS: 0239-15
		// Se a fatura for da LM a favor da Bianco, exibe opcao do cliente C&C, grupo de venda 000010
		If cEmpAnt == "07" .And. cForn == "000534"// .And. cLoja == "01"

			If !MsgYesNo("Deseja incluir títulos do cliente C&C nesta fatura?")

				cSQL += " AND E2_NUM NOT IN "+CRLF
				cSQL += " ( "+CRLF
				cSQL += " SELECT D2_DOC "+CRLF
				cSQL += " FROM SD2010 SD2 INNER JOIN SC5010 SC5 "+CRLF
				cSQL += " ON C5_FILIAL = '01' "+CRLF
				cSQL += " AND C5_NUM = D2_PEDIDO "+CRLF
				cSQL += " AND C5_CLIENTE = D2_CLIENTE "+CRLF
				cSQL += " AND C5_LOJACLI = D2_LOJA "+CRLF
				cSQL += " AND C5_YCLIORI IN (SELECT A1_COD FROM SA1010 WHERE A1_GRPVEN = '000010' AND D_E_L_E_T_='') "+CRLF
				cSQL += " AND SC5.D_E_L_E_T_ = '' "+CRLF

				cSQL += " WHERE D2_FILIAL = '01' "+CRLF
				cSQL += " AND D2_DOC = E2_NUM "+CRLF
				cSQL += " AND D2_SERIE = E2_PREFIXO "+CRLF
				cSQL += " AND D2_CLIENTE = '010064' "+CRLF
				cSQL += " AND D2_LOJA = '01' "+CRLF
				cSQL += " AND SD2.D_E_L_E_T_='' "+CRLF
				cSQL += " GROUP BY D2_DOC "+CRLF
				cSQL += " )	"+CRLF

			EndIf

		EndIf

		//OS 1611-16 - Filtrar os titulos que o receber equivalente do Cliente Final ainda nao esta baixado
		If cEmpAnt == "07" .And. ( cForn == "000534" .Or. cForn == "002912" .Or. cForn == "004695")

			cSQL += " and	( "+CRLF
			cSQL += "	(E2_YCHVSE1 = '') "+CRLF
			cSQL += "	or exists (select 1 from SE1070 X "+CRLF
			cSQL += "			where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
			cSQL += "			and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3) "+CRLF
			cSQL += "			and X.E1_NUM = Substring(E2_YCHVSE1,6,9) "+CRLF
			cSQL += "			and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1) "+CRLF
			cSQL += "			and X.E1_TIPO = Substring(E2_YCHVSE1,16,3) "+CRLF
			cSQL += "			and X.E1_BAIXA <> '' "+CRLF
			cSQL += "			and X.E1_FATURA = '' "+CRLF
			cSQL += "			and X.D_E_L_E_T_='') "+CRLF
			cSQL += "	or (
			cSQL += "			exists (select 1 from SE1070 X2 "+CRLF
			cSQL += " 					where X2.E1_FILIAL = '"+XFilial("SE1")+"' "+CRLF
			cSQL += " 					and X2.E1_PREFIXO in ('FAT','01','1','2','3','4','5') "+CRLF  //unica forma que o SQL ficou rapido - avaliar!?
			cSQL += " 					and X2.E1_NUM = (select X.E1_FATURA from SE1070 X "+CRLF
			cSQL += "		 								where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
			cSQL += "										and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3) "+CRLF
			cSQL += "										and X.E1_NUM = Substring(E2_YCHVSE1,6,9) "+CRLF
			cSQL += "										and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1) "+CRLF
			cSQL += "										and X.E1_TIPO = Substring(E2_YCHVSE1,16,3) "+CRLF
			cSQL += "										and X.D_E_L_E_T_='') "+CRLF
			cSQL += " 					and X2.E1_TIPO = 'FT'  "+CRLF
			cSQL += "					and X2.E1_FATURA = 'NOTFAT   ' "+CRLF
			cSQL += "					and X2.E1_BAIXA <> ''  "+CRLF
			cSQL += "					and X2.D_E_L_E_T_='') "+CRLF
			cSQL += "				and "+CRLF
			cSQL += "				not exists (select 1 from SE1070 X2 "+CRLF
			cSQL += "					where X2.E1_FILIAL = '01'   "+CRLF
			cSQL += "		 			and X2.E1_PREFIXO in ('FAT','01','1','2','3','4','5') "+CRLF
			cSQL += "					and X2.E1_NUM = (select X.E1_FATURA from SE1070 X   "+CRLF
			cSQL += "			 						where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
			cSQL += "									and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3)  "+CRLF
			cSQL += "									and X.E1_NUM = Substring(E2_YCHVSE1,6,9)  "+CRLF
			cSQL += "									and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1)  "+CRLF
			cSQL += "									and X.E1_TIPO = Substring(E2_YCHVSE1,16,3)  "+CRLF
			cSQL += "									and X.D_E_L_E_T_='')   "+CRLF
			cSQL += "					and X2.E1_TIPO = 'FT'  "+CRLF
			cSQL += "					and X2.E1_FATURA = 'NOTFAT   ' "+CRLF
			cSQL += "					and X2.E1_VENCREA < '"+DTOS(dDataBase-1)+"'  "+CRLF
			cSQL += "					and X2.E1_SALDO > 0  "+CRLF
			cSQL += "					and X2.D_E_L_E_T_='')  "+CRLF
			cSQL += "	) "+CRLF
			cSQL += " ) "+CRLF

		EndIf

	EndIf

Return(cSQL)
