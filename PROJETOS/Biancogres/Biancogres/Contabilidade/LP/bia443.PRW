#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA443()      // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cHist	:= ""
Private cCodLP  := Paramixb

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BIA408   ³ Autor ³ Wanisay William                          ³ Data ³ 18/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta regra 650/001, 655/001, 650/004, 655/004                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

cArq  := Alias()
cInd  := IndexOrd()
cReg  := Recno()
cHist := "BX."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)+" REF.FATURA "+ALLTRIM(SE2->E2_FATPREF)+ALLTRIM(SE2->E2_FATURA)                         

DO CASE
   CASE cCodLP $ '530010' .AND. ALLTRIM(FUNNAME()) == 'FINA290' .AND. ALLTRIM(SE2->E2_TIPO) == 'NF' 
        cHist := "BX."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)+" REF.FATURA "+ALLTRIM(SE2->E2_FATPREF)+ALLTRIM(SE2->E2_FATURA)                         
   CASE cCodLP $ '530010/530013' .AND. ALLTRIM(FUNNAME()) == 'FINA080' .AND. ALLTRIM(SE2->E2_TIPO) == 'FT' 
        cHist := "VLR. PGTO."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)                               
   CASE cCodLP $ '531010/531013' .AND. ALLTRIM(FUNNAME()) == 'FINA080' .AND. ALLTRIM(SE2->E2_TIPO) == 'NF' 
        cHist := "CNC. BX."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)+" REF.FATURA "+ALLTRIM(SE2->E2_FATPREF)+ALLTRIM(SE2->E2_FATURA)                         
   CASE cCodLP $ '531010/531013' .AND. ALLTRIM(FUNNAME()) == 'FINA080' .AND. ALLTRIM(SE2->E2_TIPO) == 'FT' 
        cHist := "CNC. VLR. PGTO."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)                               
   CASE cCodLP $ '530010/530013' .AND. ALLTRIM(SE2->E2_TIPO) == 'FT' .AND. (ALLTRIM(FUNNAME()) == 'FINA090' .OR. (ALLTRIM(FUNNAME()) == 'FINA080' .AND. SE5->E5_MOTBX == 'DEB'))  
        cHist := "VLR. BX."+ALLTRIM(SE2->E2_TIPO)+"."+ALLTRIM(SE2->E2_NUM)+" "+ALLTRIM(SE2->E2_PARCELA)+"  " +ALLTRIM(SA2->A2_NREDUZ)                               
ENDCASE

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(cHist)
