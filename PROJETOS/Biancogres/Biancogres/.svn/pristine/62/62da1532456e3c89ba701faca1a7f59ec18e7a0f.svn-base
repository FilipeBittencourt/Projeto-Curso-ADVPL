#include "rwMake.ch"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATU_CONDICAO   ºAutor  ³ BRUNO MADALENO     º Data ³  29/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ VERIFICA SE O USUARIO DIGITOU UMA CONDICAO DE PAGAMENTO DIFEREN  º±±
±±º          ³ TE DA QUE ESTA INFORMADA NA TABELA DE FORNECEDOR                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 - R4                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ATU_CONDICAO()

LOCAL CSQL := ""
LOCAL SPOS := ""

LOCAL SPRODUTO := ""
LOCAL NPRECO := ""
LOCAL NTABELA := ""
LOCAL LRET := 0 

PRIVATE ENTER	:= CHR(13)+CHR(10)

DO CASE
	// BLOQUEANDO A ALTERACAO DO PRECO NO PEDIDO DE COMPRA E AUTORIZACAO DE ENTREGA
	CASE UPPER(ALLTRIM(FUNNAME())) == "MATA121" .OR. UPPER(ALLTRIM(FUNNAME())) == "MATA122"
    
    /*
		CSQL := "SELECT A2_COND, E4_YMEDIA FROM "+RETSQLNAME("SA2")+" SA2 , SE4010 SE4 " + ENTER
		CSQL += "WHERE	SA2.A2_COD = '"+CA120FORN+"' AND " + ENTER
		CSQL += "		SA2.A2_LOJA = '"+CA120LOJ+"' AND " + ENTER
		CSQL += "		SE4.E4_CODIGO = SA2.A2_COND	AND " + ENTER
		CSQL += "		SA2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		SE4.D_E_L_E_T_ = '' " + ENTER

		IF CHKFILE("_TABELA")
			DBSELECTAREA("_TABELA")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_TABELA" NEW

		IF ! _TABELA->(EOF())
			IF POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_YMEDIA") >= _TABELA->E4_YMEDIA
				CCONDICAO := POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_CODIGO")
			ELSE
				CCONDICAO := _TABELA->A2_COND
			END IF
		ELSE
			CCONDICAO := ""
		END IF
		*/

	// BLOQUEANDO A ALTERACAO DO PRECO NO DOCUMENTO DE ENTRADA
	CASE UPPER(ALLTRIM(FUNNAME())) == "MATA103"


		SPOS := ASCAN(AHEADER,{|X| X[2]=="D1_COD    "})
		SPRODUTO := ACOLS[N,SPOS]
		SPOS := ASCAN(AHEADER,{|X| X[2]=="D1_PEDIDO "})
		SPEDIDO := ACOLS[N,SPOS]

		// SO VALIDA DO GRUPO QUE COMECA COM 1
    IF SUBSTR(Posicione("SB1",1,xFilial("SB1")+SPRODUTO,"B1_GRUPO"),1,1) <> "1"
			RETURN(.T.)
		END IF

		CSQL := "SELECT C7_COND, E4_YMEDIA FROM "+RETSQLNAME("SC7")+" SC7, SE4010 SE4 " + ENTER
		CSQL += "WHERE	C7_NUM = '"+SPEDIDO+"' AND SC7.D_E_L_E_T_ = ''  " + ENTER
		CSQL += "		AND SE4.E4_CODIGO = C7_COND " + ENTER
		CSQL += "		AND SE4.D_E_L_E_T_ = '' " + ENTER

		IF CHKFILE("_TABELA")
			DBSELECTAREA("_TABELA")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_TABELA" NEW

		IF ! _TABELA->(EOF())
			IF POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_YMEDIA") >= _TABELA->E4_YMEDIA
				CCONDICAO := POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_CODIGO")
			ELSE
				CCONDICAO := _TABELA->C7_COND
			END IF
		ELSE
			CCONDICAO := ""
		END IF
		
	// BLOQUEANDO A ALTERACAO DO PRECO NO CONTRATO DE PARCERIA
	CASE UPPER(ALLTRIM(FUNNAME())) == "MATA125"

		CSQL := "SELECT A2_COND, E4_YMEDIA FROM "+RETSQLNAME("SA2")+" SA2 , SE4010 SE4 " + ENTER
		CSQL += "WHERE	SA2.A2_COD = '"+CA125FORN+"' AND " + ENTER
		CSQL += "		SA2.A2_LOJA = '"+CA125LOJ+"' AND " + ENTER
		CSQL += "		SE4.E4_CODIGO = SA2.A2_COND	AND " + ENTER
		CSQL += "		SA2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		SE4.D_E_L_E_T_ = '' " + ENTER

		IF CHKFILE("_TABELA")
			DBSELECTAREA("_TABELA")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_TABELA" NEW

		IF ! _TABELA->(EOF())
			IF POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_YMEDIA") >= _TABELA->E4_YMEDIA
				CCONDICAO := POSICIONE("SE4",1,XFILIAL("SE4")+CCONDICAO,"E4_CODIGO")
			ELSE
				CCONDICAO := _TABELA->A2_COND
			END IF
		ELSE
			CCONDICAO := ""
		END IF

ENDCASE

RETURN(.T.)