#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT010ALT  ºAutor  ³Ranisses A. Corona  º Data ³  11/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava os campos de Grupo de Tributacao e Percentual de ICMS º±±
±±º          ³Substituicao Tributaria para produtos PA para MG         	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque/Faturamento                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function MT010ALT()
/*
If SB1->B1_GRUPO = 'PA' .And. SB1->B1_TIPO = 'PA'
DbSelectArea("SB1")
RecLock("SB1",.F.)
SB1->B1_GRTRIB	:= '001'
msUnLock()

EndIf

cGrTrib := SPACE(3)
DO CASE
	CASE SUBSTRING(SB1->B1_COD,1,1) == '0' .AND. SB1->B1_TIPO == 'PA'
		cGrTrib := '000'
	CASE SUBSTRING(SB1->B1_COD,1,1) <> '0' .AND. SB1->B1_TIPO == 'PA'
		cGrTrib := '001'
	CASE SB1->B1_GRUPO = '103'
		cGrTrib := '103'
	CASE SB1->B1_GRUPO = '104'
		cGrTrib := '104'
	CASE SUBSTRING(SB1->B1_COD,1,1) = '5'
		cGrTrib := '501'
ENDCASE
While !RecLock("SB1",.F.)
END
M->B1_GRTRIB := cGrTrib
IF SB1->B1_TIPO == 'PA'
	DbSelectArea("ZZ6")
	DbSetOrder(1)
	DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)
	IF ZZ6->ZZ6_EMP = 'B'
		M->B1_PICMRET := 45.00
	ENDIF
ENDIF
MsUnLock("SB1")*/

Return