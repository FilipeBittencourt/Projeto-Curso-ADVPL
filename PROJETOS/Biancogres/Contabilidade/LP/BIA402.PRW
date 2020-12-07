#include "rwmake.ch"

User Function BIA402()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BIA402   ³ Autor ³ Wanisay William                          ³ Data ³ 29/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta regra 650/018, 650/019, 655/018, 655/019 Pis/Cofins de Imobilizado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private cConta	:= ""
Private cCodLP  := Paramixb
Private cCf  	:= ""
Private cRegra	:= ""

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSD1	:= ""
Private cIndSD1	:= 0
Private cRegSD1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SD1")
cArqSD1 := Alias()
cIndSD1 := IndexOrd()
cRegSD1 := Recno()

DbSelectArea("SD2")
cArqSD2 := Alias()
cIndSD2 := IndexOrd()
cRegSD2 := Recno()

IF cCodLP $ '610036_610037'
	cCf    := SD2->D2_CF
	cRegra := " "
ELSE
	cCf    := SD1->D1_CF
	cRegra := SUBSTR(SD1->D1_YREGRA,1,1)
ENDIF

//Caso seja imobilizado.
//IF ALLTRIM(cCf) == "1551" .OR. ALLTRIM(cCf) == "2551" .OR. cRegra $ 'I/P' // Retirado por Marcos Alberto Soprani em 05/07/12 conforme Effettivo 1416-12
IF cRegra $ 'I/P'
	DO CASE
		CASE cCodLP == "650018" .OR. cCodLP == "655018"
			cConta := "11204017" //PIS
		CASE cCodLP == "650019" .OR. cCodLP == "655019"
			cConta := "11204018" //COFINS
		CASE cCodLP == "650002" .OR. cCodLP == "655002"
			cConta := "11204007" //ICMS
	ENDCASE
ELSE
	DO CASE
		CASE cCodLP == "650018" .OR. cCodLP == "655018" .OR. cCodLP == "610036"
			cConta := "11204014" //PIS
		CASE cCodLP == "650019" .OR. cCodLP == "655019" .OR. cCodLP == "610037"
			cConta := "11204015" //COFINS
		CASE cCodLP == "650002" .OR. cCodLP == "655002" .OR. cCodLP == "610031"
			If Alltrim(cRegra) == "N" .and. Substr(cCf,2,3) == "551"
				cConta := "11204007" //ICMS
			Else
				cConta := "11204001" //ICMS
			EndIf
	ENDCASE
ENDIF

If cArqSD1 <> ""
	dbSelectArea(cArqSD1)
	dbSetOrder(cIndSD1)
	dbGoTo(cRegSD1)
	RetIndex("SD1")
EndIf

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
	RetIndex("SD2")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(cConta)
