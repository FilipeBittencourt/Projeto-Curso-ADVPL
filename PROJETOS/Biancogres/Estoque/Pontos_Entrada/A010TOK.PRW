#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A010TOK
@author Ranisses A. Corona 
@since 11/03/09
@version 1.0
@description Bloqueio cadastro Produto com Linha duplicadas.
.            Envia email quando um novo produto for cadastrado no sistema.
@type function
/*/

User Function A010TOK()

	Private Enter	:= CHR(13) + CHR(10)
	Private lRet	:= .T.
	Private cSql	:= ""
	Private nTipo	:= ""

	IF !EMPTY(M->B1_UM) .AND. !EMPTY(M->B1_SEGUM) .AND. M->B1_CONV == 0
		lRet := .F.
		MsgAlert("Fator de conversão deverá ser preenchido!", "A010TOK[1]")
	ENDIF

	IF (M->B1_TIPO == 'PA') .and. Substr(M->B1_COD,1,1) <> 'J' // Projeto Custeio JK	
		IF !EMPTY(M->B1_YCLASSE) 
			IF SUBSTR(M->B1_COD,8,1) <> M->B1_YCLASSE
				MsgBox ("O último dígito do código do produto não pode ser diferente do campo Classe", "A010TOK[2]")
				lRet := .F.
			ENDIF
		ENDIF
	ENDIF	

	IF SUBSTR(M->B1_COD,1,1) $ "1/2" .AND. EMPTY(M->B1_YCTARES)
		lRet := .F.
		MsgAlert("A conta de resultado devera ser informada para este produto!", "A010TOK[3]")
	ENDIF

	If !cEmpAnt == "02"

		If ALLTRIM(M->B1_TIPO) $ "PA/PP" .AND. ALLTRIM(M->B1_YPCGMR3) == ""
			lRet	:= .F.
			MsgAlert("Campo Pacote GMR3 localizado na pasta 'Outros' deve estar preenchido!", "A010TOK[4]")
		EndIf

		//OBRIGA DIGITACAO DO CAMPO Categoria N->Normal / V->Victoria, PARA PRODUTOS PA
		If ALLTRIM(M->B1_TIPO) == "PA" .AND. ALLTRIM(M->B1_YCATEG) == ""
			lRet	:= .F.
			MsgAlert("O campo 'Categoria' localizado na pasta 'Outros', deve estar preenchido!", "A010TOK[5]")
		EndIf

	EndIf

	//Apenas para produtos que o codigo nao inicie com R (representante)
	If !cEmpAnt == "02"

		If Substr(M->B1_COD,1,1) <> 'R'

			//Tratamento para o campo Linha/Seq
			If Empty(Alltrim(M->B1_YLINSEQ)) .And. Alltrim(M->B1_GRUPO) == "PA"
				lRet := .F.
				MsgAlert("Favor verificar o preenchimento do campo Linha Seq. !", "A010TOK[5]")
			EndIf

			//Verifica a Descricao da Linha com a Descricao do Produto
			cSql := ""
			cSql += " SELECT	ZZ7_DESC															" + Enter
			cSql += " FROM	ZZ7010																	" + Enter
			cSql += " WHERE	ZZ7_FILIAL	= '"+xFilial("ZZ7")+"'	AND	                                " + Enter
			cSql += " 		ZZ7_COD				= '"+M->B1_YLINHA+"'		AND	                    " + Enter
			cSql += " 		ZZ7_LINSEQ		= '"+M->B1_YLINSEQ+"'		AND	                        " + Enter
			cSql += " 		ZZ7_MSBLQL 		<> '1' 									AND	            " + Enter
			cSql += " 		D_E_L_E_T_ 		= ''												    " + Enter
			If chkfile("_RAC")
				DbSelectArea("_RAC")
				DbCloseArea()
			EndIf
			TCQUERY cSql NEW ALIAS "_RAC"

			If !Alltrim(_RAC->ZZ7_DESC) $ Alltrim(M->B1_DESC) .And. Alltrim(M->B1_GRUPO) == "PA"
				lRet := .F.
				nMsg := "A Descrição do Produto: "+chr(10)
				nMsg += Alltrim(M->B1_DESC)+chr(10)
				nMsg += "não confere com a Descrição da Linha: "+chr(10)
				nMsg += Alltrim(_RAC->ZZ7_DESC)+chr(10)
				nMsg += "Favor verificar os campos Linha Cor e Linha Seq.!"
				MsgBox(nMsg,"Atenção","ALERT")
			EndIf

			//Verifica se a linha utilizada esta bloqueada
			cSql := ""
			cSql += " SELECT	COUNT(*) QUANT												" + Enter
			cSql += " FROM	ZZ7010															" + Enter
			cSql += " WHERE	ZZ7_FILIAL	= '"+xFilial("ZZ7")+"'	AND	                        " + Enter
			cSql += " 		ZZ7_COD				= '"+M->B1_YLINHA+"'		AND	            " + Enter
			cSql += " 		ZZ7_LINSEQ		= '"+M->B1_YLINSEQ+"'		AND	                " + Enter
			cSql += " 		ZZ7_MSBLQL 		=	'1' 									AND	" + Enter
			cSql += " 		D_E_L_E_T_ 		= ''											" + Enter
			If chkfile("_ZZ7")
				DbSelectArea("_ZZ7")
				DbCloseArea()
			EndIf
			TCQUERY cSql NEW ALIAS "_ZZ7"

			If _ZZ7->QUANT > 0 .And. Alltrim(M->B1_GRUPO) == "PA"
				lRet := .F.
				MsgAlert("Linha/Cor e Linha Seq. utilizada encontra-se bloqueada!", "A010TOK[7]")
			EndIf

			// BRUNO MADALENO ENVIA EMAIL PARA O SETOR DE CUSTO QUANDO UM NOVO PRODUTO FOR CADASTRADO.
			If ALLTRIM(M->B1_TIPO) = "PA" .AND. INCLUI .And. lRet

				C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
				C_HTML += '<html>'
				C_HTML += '<head>'
				C_HTML += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
				C_HTML += '  <title>blqproduto</title>'
				C_HTML += '</head>'
				C_HTML += '<body>'
				C_HTML += '<big style="font-family: Calibri;"><big><big><span style="font-size: 12pt;">Foi cadastrado um '
				C_HTML += 'novo Produto do Tipo PA na '+ IIF(CEMPANT="01","Biancogres",IIF(CEMPANT="05","Incesa","Biancogres"))+'<br>'
				C_HTML += 'C&oacute;digo do Produto: '
				C_HTML += ''+ M->B1_COD +'<br>'
				C_HTML += 'Descri&ccedil;&atilde;o do Produto: '
				C_HTML += ''+ M->B1_DESC +'</span></big></big></big>'
				C_HTML += '</body>'
				C_HTML += '</html>'

				lFormTexto		:= .T.
				aDestinatario	:= Iif(cEmpAnt=="05","giselle.vidal@biancogres.com.br;jecimar.ferreira@biancogres.com.br;osmar.feltrin@biancogres.com.br","giselle.vidal@biancogres.com.br;jecimar.ferreira@biancogres.com.br;roxana.branez@biancogres.com.br")
				aCC				:= ""
				aCCO			:= ""
				cTitulo 		:= "Inclusão de Produto PA"
				cTexto			:= C_HTML
				cErro			:= ""
				cAnexo			:= ""

				//Envia e-mail
				U_BIAEnvMail(,aDestinatario,cTitulo,cTexto,cErro,cAnexo,,aCC,aCCO )

			EndIf

		EndIf

	EndIf

	//RUBENS JUNIOR - (FACILE SISTEMAS)
	//VALIDA ALTERACAO NO CADASTRO PARA ATUALIZACAO NO VISION
	If ('SYSTEM' $ UPPER(Alltrim(GetSrvProfString("StartPath", "")))) //NAO EXECUTAR NOS AMBIENTES DE TESTE, SOMENTE NA PRODUCAO

		// Em 02/08/17.. Por Marcos Alberto Soprani... implementado para permitir a inclusão de produtos OutSourcing na Incesa
		lgEnvOut := .F.
		If Altera .And. lRet

			If Alltrim(M->B1_TIPO) $ GetMv("MV_YEXPECO") .And. (Substr(Alltrim(M->B1_COD),Len(Alltrim(M->B1_COD)),1) $ "1_2_3")

				lgEnvOut := .T.
				Processa({|| U_EXPECO(1)})

			EndIf

		EndIf

		//(Thiago Dantas - 18/09/14 ) -> Atualiza situação de Bloqueio no ECOSIS.
		// Tiago Rossini Coradini - 18/10/16 - OS: 0338-16 - Diorgenes Dias - Adicionado integracao do campo codigo de barras Protheus x Ecosis
		// Em 24/05/17... em atendimento a OS 1318-17
		If Altera .And. lRet .And. (M->B1_MSBLQL <> SB1->B1_MSBLQL .Or. M->B1_CODBAR <> SB1->B1_CODBAR .Or. M->B1_PESO <> SB1->B1_PESO .Or. lgEnvOut .Or. M->B1_YSTATUS <> SB1->B1_YSTATUS )

			msBlqProd := IIf(M->B1_MSBLQL == "1" .or. M->B1_YSTATUS $ "2/3", "1", " ")
			U_UpProdEco(M->B1_COD, msBlqProd, M->B1_CODBAR, M->B1_PESO)

		EndIf

	EndIf

	//Luana Marin Ribeiro
	//OS: 3242-15
	//verifica se produto cadastrado pertence aos grupos 101 a 107 e também ao grupo 218. Caso sim, envia email à pessoa cadastrada, informando

	If INCLUI .And. cEmpAnt=="01" .And. lRet

		If Alltrim(M->B1_GRUPO) $ "101_102_103_104_105_106_107_218"

			cDP100110 := '<html xmlns="http://www.w3.org/1999/xhtml">'
			cDP100110 += '<head>'
			cDP100110 += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
			cDP100110 += '<title>Inclusão de Produto no Grupo: ' + Trim(M->B1_GRUPO) + '</title>'
			cDP100110 += '</head>'
			cDP100110 += '<body>'
			cDP100110 += '	<p>Inclusão de Produto no Grupo: ' + Trim(M->B1_GRUPO) + '</p>'
			cDP100110 += '  <p>Produto: ' + Trim(M->B1_COD) + ' - ' + Trim(M->B1_DESC) + '</p>'
			cDP100110 += '	<p>&nbsp;</p>'
			cDP100110 += '  <p>by Protheus (A010TOK)</p>'
			cDP100110 += '</body>'
			cDP100110 += '</html>'

			df_Orig := IIF(cEmpAnt == "05", "workflow@incesa.ind.br", "workflow@biancogres.com.br")
			xCLVL   := ""
			df_Dest := U_EmailWF('A010TOK', cEmpAnt , xCLVL )

			df_Assu := "Inclusão de Produto no Grupo: " + Trim(M->B1_GRUPO)
			df_Erro := ""
			U_BIAEnvMail(df_Orig, df_Dest, df_Assu, cDP100110, df_Erro)

		EndIf

	EndIf

	If M->B1_TIPO == "PA" .and. Substr(M->B1_COD,1,1) <> 'J' // Projeto Custeio JK

		If M->B1_LOCALIZ <> "S"
			lRet := .F.
			MsgBox("Quando o TIPO do produto for PA o controle de LOCALIZAÇÃO tem que ser igual a S. Favor verificar!!!", "Atenção! (A010TOK) ")
		EndIf

		If M->B1_RASTRO <> "L"
			lRet := .F.
			MsgBox("Quando o TIPO do produto for PA o controle de RASTRO tem que ser igual a L. Favor verificar!!!", "Atenção! (A010TOK) ")
		EndIf

		If Empty(M->B1_YEMBALA)
			lRet := .F.
			MsgBox("Quando o TIPO do produto for PA o campo de EMBALAGEM tem que ser preenchido. Favor verificar!!!", "Atenção! (A010TOK) ")
		EndIf
		
		//Ticket 20226 - Bloquear Produtos PA - Sem preenchimento de campos base e acabamento (Pablo Nascimento)
		If (M->B1_RASTRO == 'L' .And. M->B1_YFORMAT <> '' .And. B1_MSBLQL <> '1' .And. ( Empty(Alltrim(M->B1_YACABAM)) .Or. Empty(Alltrim(M->B1_YBASE))))
			lRet := .F.
			MsgBox("Quando o TIPO do produto for PA os campos de ACABAMENTO e BASE têm que ser preenchidos. Favor verificar!!!", "Atenção! (A010TOK) ")
		EndIf

	EndIf

Return(lRet)
