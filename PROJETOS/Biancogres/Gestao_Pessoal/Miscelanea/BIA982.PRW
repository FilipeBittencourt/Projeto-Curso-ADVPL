#include "rwMake.ch"
#include "Topconn.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � BIA892   � Autor � Ranisses A. Corona    � Data � 19/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera arquivo para envio do Banestik                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAGPE                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA982() 

//��������������������������������������������������������������������������Ŀ
//� Exibe janela com descritivo do programa                                  �
//����������������������������������������������������������������������������
@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Geracao do Arquivo Banestik"
@ 8,10 TO 84,222

@ 16,12 SAY "Este programa tem por finalidade: "
@ 24,12 SAY "Gerar o arquivo com os pedidos de Credito e Cartao para o Banestik"


@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA982",.T.)
@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)

ACTIVATE DIALOG oDlg5 CENTERED

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OkProc    � Autor �Gustav Koblinger Junior� Data � 15.02.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Confirma o Processamento                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OkProc()
Processa( {|| RunProc() } )
Close(oDlg5)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RunProc   � Autor � Ary Medeiros          � Data � 15.02.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Executa o Processamento                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RunProc()

Private cEOL	 := "CHR(13)+CHR(10)"
Private nQuant := 0
Private nTotal := 0
Private cArqTxt, nHdl

Enter := chr(13) + Chr(10)

If Empty(cEOL)
    cEOL := CHR(13)+CHR(10)
Else
    cEOL := Trim(cEOL)
    cEOL := &cEOL
Endif

//Abre o arquivo
cArqTxt := alltrim(MV_PAR03)
nHdl    := fCreate(cArqTxt)

cSql := ""
cSql += " SELECT MAX(ZS_SEQ) AS ZS_SEQ, "
cSql += "        SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),7,2)+SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),5,2)+SUBSTRING(CONVERT(VARCHAR(8),GETDATE(),112),1,4) AS DTATUAL "
cSql += " FROM 	" + RetSqlName("SZS") + " SZS "
cSql += " WHERE SZS.ZS_MESANO	= '"+MV_PAR01+"'	AND "
cSql += " 		SZS.ZS_SEQ		= '"+MV_PAR02+"'	AND "
cSql += "		SZS.D_E_L_E_T_	= '' "
If chkfile("RZ")
	DbSelectArea("RZ")
	DbCloseArea("RZ")
EndIf
TCQUERY cSql ALIAS "RZ" NEW


//Monta Registro HEADER
cLin	:= "H"+SM0->M0_CGC+RZ->ZS_SEQ+RZ->DTATUAL+"BANESTIK0"
fWrite(nHdl,cLin+cEOL)

//Monta Registro DETALHER
cSql := ""
cSql += " SELECT RA_MAT, RA_NOME, RA_CIC, ZS_TIPO, ZS_MESANO, ZS_OBS, ZS_SEQ, ZS_VALOR, " 
cSql += " 		 SUBSTRING((REPLICATE(0,12-CONVERT(INT,LEN(LTRIM(STR(ZS_VALOR,12)+SUBSTRING(STR(ZS_VALOR,12,2), LEN(STR(ZS_VALOR,12,2)) - 1,2)))))+LTRIM(STR(ZS_VALOR,12)+SUBSTRING(STR(ZS_VALOR,12,2), LEN(STR(ZS_VALOR,12,2)) - 1,2))),0,13) AS ZS_VALOR1, "
cSql += "        SUBSTRING(ZS_DTPAG,7,2)+SUBSTRING(ZS_DTPAG,5,2)+SUBSTRING(ZS_DTPAG,1,4) AS ZS_DTPAG, " 
cSql += "        SUBSTRING(RA_NASC,7,2)+SUBSTRING(RA_NASC,5,2)+SUBSTRING(RA_NASC,1,4) AS RA_NASC " 
cSql += " FROM 	" + RetSqlName("SZS") + " SZS, " + RetSqlName("SRA") + " SRA "
cSql += " WHERE SZS.ZS_MAT = SRA.RA_MAT AND "	
cSql += " 		SZS.ZS_MESANO	= '"+MV_PAR01+"'	AND "
cSql += " 		SZS.ZS_SEQ		= '"+MV_PAR02+"'	AND "
cSql += "		SZS.D_E_L_E_T_	= '' AND "
cSql += "		SRA.D_E_L_E_T_	= '' "
If chkfile("RZ")
	DbSelectArea("RZ")
	DbCloseArea("RZ")
EndIf
TCQUERY cSql ALIAS "RZ" NEW


While !RZ->(Eof())
	If RZ->ZS_TIPO == "1" // Pedido de Credito
		If RZ->ZS_VALOR > 0 
			nQuant  := nQuant + 1  
			cLin	:=	"C00000"+RZ->RA_MAT+"15"+RZ->ZS_DTPAG+RZ->ZS_VALOR1
			fWrite(nHdl,cLin+cEOL)
			DbSelectArea("RZ")
			dbSkip()
		Else
			DbSelectArea("RZ")
			dbSkip()
		EndIf
	ElseIf RZ->ZS_TIPO == "2" // Pedido de Cartao
		nQuant  := nQuant + 2
		cLin	:=	"B00000"+RZ->RA_MAT+Subs(RZ->RA_NOME,1,50)+Subs(RZ->RA_NOME,1,30)+"          "+RZ->RA_CIC+RZ->RA_NASC+"1500000001"
		fWrite(nHdl,cLin+cEOL)
		cLin	:=	"C00000"+RZ->RA_MAT+"15"+RZ->ZS_DTPAG+"            "
		fWrite(nHdl,cLin+cEOL)
		DbSelectArea("RZ")
		dbSkip()
	ElseIf RZ->ZS_TIPO == "3" //Pedido de Cartao e Credito
		nQuant  := nQuant + 2
		cLin	:=	"B00000"+RZ->RA_MAT+Subs(RZ->RA_NOME,1,50)+Subs(RZ->RA_NOME,1,30)+"          "+RZ->RA_CIC+RZ->RA_NASC+"1500000001"
		fWrite(nHdl,cLin+cEOL)
		cLin	:=	"C00000"+RZ->RA_MAT+"15"+RZ->ZS_DTPAG+RZ->ZS_VALOR
		DbSelectArea("RZ")
		dbSkip()
	EndIf
End

//Monta Registro TRAILER
cSql := ""
cSql += " SELECT SUBSTRING((REPLICATE(0,12-CONVERT(INT,LEN(LTRIM(STR(SUM(ZS_VALOR),12)+SUBSTRING(STR(SUM(ZS_VALOR),12,2), LEN(STR(SUM(ZS_VALOR),12,2)) - 1,2)))))+LTRIM(STR(SUM(ZS_VALOR),12)+SUBSTRING(STR(SUM(ZS_VALOR),12,2), LEN(STR(SUM(ZS_VALOR),12,2)) - 1,2))),0,13) AS ZS_VALOR1 "
cSql += " FROM 	" + RetSqlName("SZS") + " SZS "
cSql += " WHERE SZS.ZS_MESANO	= '"+MV_PAR01+"'	AND "
cSql += " 		SZS.ZS_SEQ		= '"+MV_PAR02+"'	AND "
cSql += "		SZS.D_E_L_E_T_	= '' "
If chkfile("RZ")
	DbSelectArea("RZ")
	DbCloseArea("RZ")
EndIf
TCQUERY cSql ALIAS "RZ" NEW

cLin	:=	"T"+REPLICATE('0',6-Len(Alltrim(Str(nQuant))))+Alltrim(Str(nQuant))+RZ->ZS_VALOR1
fWrite(nHdl,cLin+cEOL)
                                                                                                              
//Fecha o arquivo
fClose(nHdl)	

MsgAlert("Arquivo Gerado com Sucesso!")

DbSelectArea("RZ")
DbCloseArea()

Return