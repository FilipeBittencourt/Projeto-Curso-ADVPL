#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA443()      // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Private cHist	:= ""
Private cCodLP  := Paramixb

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma  � BIA408   � Autor � Wanisay William                          � Data � 18/02/08 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri뇚o � Ajusta regra 650/001, 655/001, 650/004, 655/004                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿢so       � SIGACOM                                                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
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
