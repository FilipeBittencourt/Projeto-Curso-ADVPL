#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TRANS_REP� Autor � MADALENO              � Data � 09/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ROTINA PARA TRANSFERIR UM VENDEDOR PARA O OUTRO            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MP 10                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION TRANS_REP()
PRIVATE CSQL := ""
PRIVATE ENTER := CHR(13)+CHR(10)

nLastKey := PERGUNTE("TRAN_REPRE",.T.)
IF !nLastKey
	RETURN()
ENDIF

IF ALLTRIM(MV_PAR01) = "" .OR. ALLTRIM(MV_PAR02) = "" .OR. MV_PAR03 = 0
	ALERT("EXISTE PARAMETROS OBRIGATORIOS SEM PREENCHIMENTO")
	RETURN(.F.)
END IF

IF CEMPANT == "01" .OR. CEMPANT == "07"
	
	_COMISSAO	:= Posicione("SA3",1,xFilial("SA3")+MV_PAR02,"A3_COMIS")
	IF _COMISSAO <= MV_PAR03
		ALERT("COMISSAO INFORMADA N�O PODE SER MAIOR QUE A COMISSAO DO REPRESENTANTE")
		RETURN(.F.)
	ELSE
		CSQL := "UPDATE SA1010 SET A1_VEND = '"+MV_PAR02+"', A1_COMIS = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_VEND = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
		
		CSQL := "UPDATE SA1050 SET A1_VEND = '"+MV_PAR02+"', A1_COMIS = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_VEND = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
		
		CSQL := "UPDATE SA1070 SET A1_VEND = '"+MV_PAR02+"', A1_COMIS = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_VEND = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
	END IF
ELSE

	_COMISSAO	:= Posicione("SA3",1,xFilial("SA3")+MV_PAR02,"A3_YCOMISI")
	IF _COMISSAO <= MV_PAR03
		ALERT("COMISSAO INFORMADA N�O PODE SER MAIOR QUE A COMISSAO DO REPRESENTANTE")
		RETURN(.F.)
	ELSE	
		CSQL := "UPDATE SA1010 SET A1_YVENDI = '"+MV_PAR02+"', A1_YCOMISI = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_YVENDI = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
		
		CSQL := "UPDATE SA1050 SET A1_YVENDI = '"+MV_PAR02+"', A1_YCOMISI = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_YVENDI = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
		
		CSQL := "UPDATE SA1070 SET A1_YVENDI = '"+MV_PAR02+"', A1_YCOMISI = '"+ALLTRIM(STR(MV_PAR03))+"' " + ENTER
		CSQL += "WHERE	A1_YVENDI = '"+MV_PAR01+"' AND " + ENTER
		CSQL += "		D_E_L_E_T_ = '' " + ENTER
		TCSQLEXEC(CSQL)
	END IF
END IF


// ATUALIZANDO O PEDIDO
CSQL := "UPDATE "+RETSQLNAME("SC5")+" SET C5_VEND1 = '"+MV_PAR02+"'  " + ENTER
CSQL += "FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SC6")+" SC6  " + ENTER
CSQL += "WHERE	C5_VEND1 = '"+MV_PAR01+"' AND  " + ENTER
CSQL += "		C5_NUM = C6_NUM AND  " + ENTER
CSQL += "		C6_QTDVEN <> C6_QTDENT AND  " + ENTER
CSQL += "		C6_BLQ <> 'R' AND  " + ENTER
CSQL += "		SC5.D_E_L_E_T_ = '' AND  " + ENTER
CSQL += "		SC6.D_E_L_E_T_ = '' " + ENTER
TCSQLEXEC(CSQL)

CSQL := "UPDATE "+RETSQLNAME("SE1")+" SET E1_VEND1 = '"+MV_PAR02+"'  " + ENTER
CSQL += "WHERE E1_FILIAL = '01'  " + ENTER
CSQL += "AND E1_VEND1 = '"+MV_PAR01+"'  " + ENTER
CSQL += "AND E1_SALDO > 0  " + ENTER
CSQL += "AND D_E_L_E_T_ = ' ' 		 " + ENTER
TCSQLEXEC(CSQL)

CSQL := "UPDATE "+RETSQLNAME("SE3")+" SET E3_VEND = '"+MV_PAR02+"'  " + ENTER
CSQL += "WHERE E3_VEND = '"+MV_PAR01+"'  " + ENTER
CSQL += "AND E3_DATA = ' '  " + ENTER
CSQL += "AND D_E_L_E_T_ = ' ' " + ENTER
TCSQLEXEC(CSQL)

RETURN
