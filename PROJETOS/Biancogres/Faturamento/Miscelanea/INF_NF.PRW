#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ INF_NF         ºAUTOR  ³ BRUNO MADALENO     º DATA ³  19/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ TELA PARA VINCULAR A PESAGEM COM A NOTA FISCAL                   º±±
±±º          ³																	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 8                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION INF_NF()

	LOCAL NOPC := GD_INSERT+GD_DELETE+GD_UPDATE
	PRIVATE ACOBRW1 := {}
	PRIVATE AHOBRW1 := {}
	PRIVATE NOBRW1  := 0

	SETPRVT("ODLG1","OBRW1")

	//RegToMemory("Z12",.F.)

	ODLG1      := MSDIALOG():NEW( 095,232,325,800,"NOTA FISCAL",,,.F.,,,,,,.T.,,,.T. )
	ODLG1:BINIT := {||ENCHOICEBAR(ODLG1,{||__CONFIRMA()},{||ODLG1:END()},.F.,{})}
	MHOBRW1()
	OBRW1      := MSNEWGETDADOS():NEW(024,004,100,268,NOPC,'ALLWAYSTRUE()','ALLWAYSTRUE()','',,0,99,'ALLWAYSTRUE()','','ALLWAYSTRUE()',ODLG1,AHOBRW1)
	PREENCHE_ACOLS()
	ODLG1:ACTIVATE(,,,.T.)

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ PREENCHE_ACOLS ºAUTOR  ³ BRUNO MADALENO     º DATA ³  11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ ROTINA RESPONSAVEL EM MONTAR O ACOLS  NOME ACOLS                 º±±
±±º          ³																	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION PREENCHE_ACOLS()
	LOCAL _CSQL := ""
	OBRW1:ACOLS := {}

	_CSQL := "SELECT * FROM "+RETSQLNAME("Z12")+" "
	_CSQL += "WHERE	Z12_PESAGE = '"+Z11->Z11_PESAGE+"' AND  "
	_CSQL += "		D_E_L_E_T_ = '' "
	IF CHKFILE("__TRAB")
		DBSELECTAREA("__TRAB")
		DBCLOSEAREA()
	ENDIF
	TCQUERY _CSQL ALIAS "__TRAB" NEW
	I := 1

	IF __TRAB->(EOF())
		AADD(OBRW1:ACOLS,ARRAY(NOBRW1+1))
		OBRW1:ACOLS[I][1] := __TRAB->Z12_NFISC
		OBRW1:ACOLS[I][2] := __TRAB->Z12_EMP   // 1 CAMPO DE NOTA FISCAL	   	   	
		OBRW1:ACOLS[I][3] := .F.
	ELSE
		DO WHILE ! __TRAB->(EOF())
			AADD(OBRW1:ACOLS,ARRAY(NOBRW1+1))
			OBRW1:ACOLS[I][1] := __TRAB->Z12_NFISC   // 1 CAMPO DE NOTA FISCAL
			OBRW1:ACOLS[I][2] := __TRAB->Z12_EMP   // 1 CAMPO DE NOTA FISCAL	   	
			OBRW1:ACOLS[I][3] := .F.				// 	2 CAMPO DE DELETADO
			__TRAB->(DBSKIP())
			I++	
		END OF 
	END IF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ __CONFIRMA     ºAUTOR  ³ BRUNO MADALENO     º DATA ³  11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ ROTINA RESPONSAVEL GRAVAR AS NOTAS QUANDO CONFIRMADO A TELA      º±±
±±º          ³																	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION __CONFIRMA()

	Local I

	CSQL := "UPDATE "+RETSQLNAME("Z12")+" SET D_E_L_E_T_ = '*' "
	CSQL += "WHERE	Z12_PESAGE = '"+Z11->Z11_PESAGE+"' AND "
	CSQL += "		D_E_L_E_T_ = '' "
	TCSQLExec(CSQL)


	DBSELECTAREA("Z12")
	FOR I := 1 TO LEN(OBRW1:ACOLS)
		IF OBRW1:ACOLS[I][3] = .F. // NAO GRAVA POIS O REGISTRO ESTA DELETADO
			RecLock("Z12",.T.)
			Z12->Z12_FILIAL 	= "  "
			Z12->Z12_PESAGE 	= Z11->Z11_PESAGE
			Z12->Z12_NFISC 		= OBRW1:ACOLS[I][1]
			Z12->Z12_EMP 		= OBRW1:ACOLS[I][2]
			MSUNLOCK() 
		END IF
	NEXT

	ODLG1:END()

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MHOBRW1        ºAUTOR  ³ BRUNO MADALENO     º DATA ³  11/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ ROTINA RESPONSAVEL EM MONTAR O AHEADER DO MS GETDADOS            º±±
±±º          ³																	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MHOBRW1()

	DBSELECTAREA("SX3")
	DBSETORDER(1)
	DBSEEK("Z12")
	WHILE !EOF() .AND. SX3->X3_ARQUIVO == "Z12"
		IF X3USO(SX3->X3_USADO) .AND. CNIVEL >= SX3->X3_NIVEL
			IF SX3->X3_CAMPO <> "Z12_FILIAL" .AND. SX3->X3_CAMPO <> "Z12_PESAGE"
				NOBRW1++
				AADD(AHOBRW1,{TRIM(X3TITULO()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				"",;
				SX3->X3_TIPO,;
				"",;
				"" } )
			END IF	
		ENDIF
		DBSKIP()
	END
RETURN