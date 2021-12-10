#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATU_PEDIDO     ºAutor  ³BRUNO MADALENO      º Data ³  15/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ATUALIZA O ACOLS DO PEDIDO QUANDO ALTERADO CAMPOS CHAVES NO      º±±
±±º          ³ CABECALHO                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION ATU_PEDIDO()

	Local I
	Local LLRETORNO

	// Tiago Rossini Coradini - Facile Sistemas - Data: 29/10/14
	// Bloco comentado para não limpar mais os campos: C6_PRCVEN e C6_TES
	// o contrudo dos campos esta sendo preenchido na função BIAF008.

	SPOS := ASCAN(AHEADER,{|X| X[2]=="C6_PRCVEN "})
	nPosTes := ASCAN(AHEADER,{|X| ALLTRIM(X[2])=="C6_TES"})
	FOR I := 1 TO LEN(ACOLS)
		ACOLS[I,SPOS] := 0
		ACOLS[I,nPosTes] := "   "
	NEXT

	//Fernando/Facile em 03/09/2015 - OS 2318-15 - Pedidos de Amostra
	IF ALLTRIM(__READVAR) = 'M->C5_YSUBTP'

		If !Empty(M->C5_YSUBTP) .And. AllTrim(M->C5_YSUBTP) $ "A#M"

			If AllTrim(M->C5_YSUBTP) == "A"
				M->C5_YITEMCT := 'I0105'
				M->C5_YCC     := '2000'

				// Tiago Rossini Coradini - Facile Sistemas - Data: 08/12/15 - OS: 3902-15 - Aline Correa - Tratamento de classes de valor por linha
				If AllTrim(M->C5_YLINHA) == "1" // Linha Bianco classe de valor 2100
					M->C5_YCLVL := '2105'
				ElseIf AllTrim(M->C5_YLINHA) == "6"
					M->C5_YCLVL := '2302'
				Else
					M->C5_YCLVL := '2205'
				EndIf

			Else
				M->C5_YITEMCT := 'I0104'
				M->C5_YCC     := '2000'
				//M->C5_YCLVL   := '2100'

				// Luana Marin Ribeiro - OS: 1828-16 - Aline Salvalaio - Tratamento de classes de valor por linha
				If AllTrim(M->C5_YLINHA) == "1" // Linha Bianco classe de valor 2118
					M->C5_YCLVL := '2118'
				Else
					M->C5_YCLVL := '2218'
				EndIf
			EndIf

		Else

			M->C5_YITEMCT := Space(Len(M->C5_YITEMCT))
			M->C5_YCC     := Space(Len(M->C5_YCC))
			M->C5_YCLVL   := Space(Len(M->C5_YCLVL))

		EndIf

	ENDIF

	// OS: 0652-14 - Usuário: Elaine Cristina Sales
	// U_BIAMsgRun("Atualizando Itens...", "Aguarde!", {|| U_BIAF008(oGetDad) })
	LLRETORNO := ""
	IF ALLTRIM(__READVAR) = 'M->C5_YLINHA'
		LLRETORNO := M->C5_YLINHA

	ELSEIF ALLTRIM(__READVAR) = 'M->C5_YSUBTP'
		LLRETORNO := M->C5_YSUBTP

	ELSEIF ALLTRIM(__READVAR) = 'M->C5_CONDPAG'
		LLRETORNO := M->C5_CONDPAG

	ELSEIF ALLTRIM(__READVAR) = 'M->C5_VLRFRET'
		LLRETORNO := M->C5_VLRFRET

	ELSEIF ALLTRIM(__READVAR) = 'M->C5_YMAXCND'
		LLRETORNO := M->C5_YMAXCND

	ELSEIF ALLTRIM(__READVAR) = 'M->C5_TABELA'
		LLRETORNO := M->C5_TABELA

		// Inicio - Ticket - 31051
	ELSEIF ALLTRIM(__READVAR) = 'M->C5_YSEGFAB'
		LLRETORNO := M->C5_YSEGFAB

	END IF

RETURN(LLRETORNO)
