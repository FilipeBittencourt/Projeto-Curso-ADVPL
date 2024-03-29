#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function MA260D3
If cempant == "02"
	lop := MsgBox("Deseja atualizar o custo da entrada da transferencia para 0.0001?","Atencao","YESNO")
	If lop == .F.
		Return
	EndIf
	If SD3->D3_COD == CCODDEST
		If Reclock("SD3",.f.)
			SD3->D3_CF     := "DE6"
			SD3->D3_CUSTO1 := 0.0001
			SD3->D3_CUSTO2 := 0.0001
			SD3->D3_CUSTO3 := 0.0001
			SD3->D3_CUSTO4 := 0.0001
			SD3->D3_CUSTO5 := 0.0001
			MsUnlock()
		EndIf
	EndIf
EndIf

		    

Return
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis.																	  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cD3_DOC := M->CDOCTO
If Empty(cD3_DOC)
   Return
EndIf

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � MA260D3    � Autor � Cesar Magnago		  � Data � 14/09/01 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Calcula Quantidade da Amostra no MATA260                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � SIGAEST									      				|굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
cQuery  := ""
cQuery  += "SELECT COUNT(SD3.D3_DOC) AS TOTREGS "
cQuery  += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery  += "WHERE "
cQuery  += "SD3.D3_FILIAL        =  '"+xFilial("SD3")+"'	AND "
cQuery  += "SD.D3_DOC            =  '"+cD3_DOC+"'			AND "
cQuery  += "SD.D3_TM             =  '499'					AND "
cQuery  += "D_E_L_E_T_ <> '*'"
cQuery  += cQuery
TcQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

If nTotRegs > 0
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao de indice temporario.                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cQuery  := ""
	cQuery  += "SELECT SD3.D3_DOC, SD3.D3_QUANT, SD3.D3_QTSEGUM, SD3.D3_TM, SD3.D3_COD, SD3.D3_CF, SB1.B1_COD, SB1.B1_TIPCONV, SB1.B1_CONV "
	cQuery  += "FROM "+RetSqlName("SD3")+" SD3, "+RetSqlName("SB1")+" SB1 "
	cQuery  += "WHERE "
	cQuery  += "SD3.D3_FILIAL         =  '"+xFilial("SD3")+"'	AND "
	cQuery  += "SD3.D3_DOC            =  '"+cD3_DOC+"'			AND "
	cQuery  += "SD3.D3_TM             =  '499'					AND "
	cQuery  += "SB1.B1_COD            =  D3_COD					AND "
	cQuery  += "SD3.D_E_L_E_T_ <> '*' 						    AND "
	cQuery  += "SB1.D_E_L_E_T_ <> '*'"
	cQuery  += cQuery
	TcQuery cQuery Alias "QRY" New
	DbSelectArea("QRY")
	
   While !EOF()                
      DbSelectArea("SD3")
      DbSeek(xFilial("SD3")+QRY->D3_DOC+QRY->D3_COD,.F.)
      RecLock("SD3",.F.)
  		SD3->D3_QUANT   := Round(If(QRY->B1_TIPCONV=="D",SD3->D3_QUANT*QRY->B1_CONV,SD3->D3_QUANT/QRY->B1_CONV),0)
      SD3->D3_QUANT := QRY->D3_QTSEGUM
		SD3->D3_QTSEGUM := Round(If(QRY->B1_TIPCONV=="D",SD3->D3_QUANT/QRY->B1_CONV,SD3->D3_QUANT*QRY->B1_CONV),2)
  		MsUnLock()
		DbSelectArea("QRY")
		DbSkip()
	EndDo  
	DbCloseArea("QRY")
EndIf  
Return
