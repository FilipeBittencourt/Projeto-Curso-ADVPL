#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia206cd()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_ACAMPOS,_Z2,XDIAS,XPRZMD,XMTPRZMD,WDATAANTIGA")
SetPrvt("NQTDESTQ,WNOVADATA,XDATA,LEMP,CCH,TCLSA1")
SetPrvt("TCLSA2,TCLSA3,TCLSB1,TCLSB2,TCLSB3,TCLSC1")
SetPrvt("TCLSC2,TCLSC3,TCLS,WCLS,WSALDO,")
Private cformato
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ BIA206CD ³ Autor ³ Marcelo Ventura Felix  ³ Data ³10/03/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Coleta de dados do arquivo gerencial                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Montagem dos Dados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aCampos := {}
aadd(_aCampos,{"Z2_FORMATO","C", 1,0})
aadd(_aCampos,{"Z2_TIPO   ","C", 1,0})
aadd(_aCampos,{"Z2_DESCRI ","C",13,0})
aadd(_aCampos,{"Z2_QTPRD  ","N",15,2})
aadd(_aCampos,{"Z2_PCPRD  ","N", 7,2})
aadd(_aCampos,{"Z2_MQPRD  ","N",15,2})
aadd(_aCampos,{"Z2_AQPRD  ","N", 7,2})
aadd(_aCampos,{"Z2_QTLIB  ","N",15,2})
aadd(_aCampos,{"Z2_PCLIB  ","N", 7,2})
aadd(_aCampos,{"Z2_MQLIB  ","N",15,2})
aadd(_aCampos,{"Z2_AQLIB  ","N", 7,2})
aadd(_aCampos,{"Z2_QTPDEM ","N",15,2})
aadd(_aCampos,{"Z2_MQPDEM ","N",15,2})
aadd(_aCampos,{"Z2_AQPDEM ","N", 7,2})
aadd(_aCampos,{"Z2_VLPDEM ","N",16,2})
aadd(_aCampos,{"Z2_MVPDEM ","N",16,2})
aadd(_aCampos,{"Z2_AVPDEM ","N", 7,2})
aadd(_aCampos,{"Z2_QTFAT  ","N",15,2})
aadd(_aCampos,{"Z2_MQFAT  ","N",15,2})
aadd(_aCampos,{"Z2_AQFAT  ","N", 7,2})
aadd(_aCampos,{"Z2_VLFAT  ","N",16,2})
aadd(_aCampos,{"Z2_IMFAT  ","N",10,2})
aadd(_aCampos,{"Z2_LQFAT  ","N",16,2})
aadd(_aCampos,{"Z2_COFAT  ","N",10,2})
aadd(_aCampos,{"Z2_MBFAT  ","N",16,2})
aadd(_aCampos,{"Z2_MVMB   ","N",16,2})
aadd(_aCampos,{"Z2_AVMB   ","N", 7,2})
aadd(_aCampos,{"Z2_CUSTO  ","N",16,2})
aadd(_aCampos,{"Z2_VLMC   ","N",16,2})
aadd(_aCampos,{"Z2_MVMC   ","N",15,2})
aadd(_aCampos,{"Z2_AVMC   ","N",15,2})
aadd(_aCampos,{"Z2_QTEXP  ","N",15,2})
aadd(_aCampos,{"Z2_MQEXP  ","N",15,2})
aadd(_aCampos,{"Z2_AQEXP  ","N", 7,2})
aadd(_aCampos,{"Z2_QTATU  ","N",15,2})
aadd(_aCampos,{"Z2_QTPED  ","N",15,2})
aadd(_aCampos,{"Z2_QTDISP ","N",15,2})
aadd(_aCampos,{"Z2_MDFAT  ","N",15,2})
aadd(_aCampos,{"Z2_MDLIQ  ","N",15,2})
aadd(_aCampos,{"Z2_MTMDLIQ","N",15,2})
aadd(_aCampos,{"Z2_ATMDLIQ","N", 7,2})
aadd(_aCampos,{"Z2_MDMC   ","N",15,2})
aadd(_aCampos,{"Z2_MTMDMC ","N",15,2})
aadd(_aCampos,{"Z2_AVMDMC ","N",9,2})
aadd(_aCampos,{"Z2_PRZMD  ","N", 5,0})
aadd(_aCampos,{"Z2_MTPRZMD","N", 5,0})
aadd(_aCampos,{"Z2_DIPRZ  ","N", 5,0})

_Z2 := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,,_Z2,"_Z2")
DbCreateInd(_Z2,"Z2_FORMATO+Z2_TIPO",{||Z2_FORMATO+Z2_TIPO})

//msgalert(_z2)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tamanho da regua                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("UZ2")
//If Alltrim(funname()) == "#BIA205"
   If mv_par03 == 1
      cformato := Alltrim(GETMV("MV_YBIANCO"))
   Elseif mv_par03 == 2
      cformato := Alltrim(GETMV("MV_YINCESA"))
   EndIf
   Set Filter to Z2_FORMATO $ cformato .or. Z2_FORMATO == "@"
//EndIf   
ProcRegua(UZ2->(LASTREC()))
DbGoTop()

xDias       := 0
xPRZMD      := 0
xMTPRZMD    := 0
wDataAntiga := ctod("01/01/19000")
nQtdEstq    := 0 // Somat¢rio do Estoque

do while !UZ2->(EOF())
   
   IncProc("Processando ...")
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data no resumo gerencial pertence ao periodo especificado nos parametros. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   IF (UZ2->Z2_DATA < MV_PAR01) .OR. (UZ2->Z2_DATA > MV_PAR02)
      UZ2->(DBSKIP())
      LOOP
   ENDIF

   xDias := xDias + 1
   xData := UZ2->Z2_DATA
   lEmp  := .F.

   DO WHILE (UZ2->Z2_DATA == xData) .AND. !UZ2->(EOF())
      DbSelectArea("_Z2")
      DbSeek(UZ2->Z2_FORMATO+UZ2->Z2_TIPO)

      if _Z2->(EOF())
         DbSelectArea("SX5")
         SX5->(DbSeek("  U1"+UZ2->Z2_FORMATO+UZ2->Z2_TIPO, .T.))

         DbSelectArea("_Z2")
         RecLock("_Z2", .T. )
         _Z2->Z2_FORMATO := ALLTRIM(UZ2->Z2_FORMATO)
         _Z2->Z2_TIPO    := UZ2->Z2_TIPO
         _Z2->Z2_DESCRI  := If(UZ2->Z2_FORMATO#"@",SX5->X5_DESCRI,"")
      else
         RecLock("_Z2", .F. )
      endif

      _Z2->Z2_QTPRD   := _Z2->Z2_QTPRD   + UZ2->Z2_QTPRD   //  N,15,2
      _Z2->Z2_MQPRD   := _Z2->Z2_MQPRD   + UZ2->Z2_MQPRD   //  N,15,2
      _Z2->Z2_AQPRD   := iif(_Z2->Z2_MQPRD == 0,0,(_Z2->Z2_QTPRD / _Z2->Z2_MQPRD)*100)
      _Z2->Z2_QTLIB   := _Z2->Z2_QTLIB   + UZ2->Z2_QTLIB   //  N,15,2
      _Z2->Z2_MQLIB   := _Z2->Z2_MQLIB   + UZ2->Z2_MQLIB   //  N,15,2
      _Z2->Z2_AQLIB   := iif(_Z2->Z2_MQLIB == 0,0,(_Z2->Z2_QTLIB / _Z2->Z2_MQLIB)*100)
      _Z2->Z2_QTPDEM  := _Z2->Z2_QTPDEM  + UZ2->Z2_QTPDEM  //  N,15,2
      _Z2->Z2_MQPDEM  := _Z2->Z2_MQPDEM  + UZ2->Z2_MQPDEM  //  N,15,2
      _Z2->Z2_AQPDEM  := iif(_Z2->Z2_MQPDEM == 0,0,(_Z2->Z2_QTPDEM / _Z2->Z2_MQPDEM)*100)
      _Z2->Z2_VLPDEM  := _Z2->Z2_VLPDEM  + UZ2->Z2_VLPDEM  //  N,16,2
      _Z2->Z2_MVPDEM  := _Z2->Z2_MVPDEM  + UZ2->Z2_MVPDEM  //  N,16,2
      _Z2->Z2_AVPDEM  := iif(_Z2->Z2_MVPDEM == 0,0,(_Z2->Z2_VLPDEM / _Z2->Z2_MVPDEM)*100)
      _Z2->Z2_QTFAT   := _Z2->Z2_QTFAT   + UZ2->Z2_QTFAT   //  N,15,2
      _Z2->Z2_MQFAT   := _Z2->Z2_MQFAT   + UZ2->Z2_MQFAT   //  N,15,2
      _Z2->Z2_AQFAT   := iif(_Z2->Z2_MQFAT == 0,0,(_Z2->Z2_QTFAT / _Z2->Z2_MQFAT)*100)
      _Z2->Z2_VLFAT   := _Z2->Z2_VLFAT   + UZ2->Z2_VLFAT   //  N,16,2
      _Z2->Z2_IMFAT   := _Z2->Z2_IMFAT   + UZ2->Z2_IMFAT   //  N, 9,2
      _Z2->Z2_LQFAT   := _Z2->Z2_LQFAT   + UZ2->Z2_LQFAT   //  N,16,2
      _Z2->Z2_COFAT   := _Z2->Z2_COFAT   + UZ2->Z2_COFAT   //  N,10,2
      _Z2->Z2_MBFAT   := _Z2->Z2_MBFAT   + UZ2->Z2_MBFAT   //  N,16,2
      _Z2->Z2_MVMB    := _Z2->Z2_MVMB    + UZ2->Z2_MVMB    //  N,16,2
      _Z2->Z2_AVMB    := iif(_Z2->Z2_MVMB == 0,0,(_Z2->Z2_MBFAT / _Z2->Z2_MVMB) * 100)
      _Z2->Z2_CUSTO   := _Z2->Z2_CUSTO   + UZ2->Z2_CUSTO   //  N,16,2
      _Z2->Z2_VLMC    := _Z2->Z2_VLMC    + UZ2->Z2_VLMC    //  N,16,2
      _Z2->Z2_MVMC    := _Z2->Z2_MVMC    + UZ2->Z2_MVMC    //  N,15,2
      _Z2->Z2_AVMC    := iif(_Z2->Z2_MVMC == 0,0,(_Z2->Z2_VLMC / _Z2->Z2_MVMC ) * 100)
      _Z2->Z2_QTEXP   := _Z2->Z2_QTEXP   + UZ2->Z2_QTEXP   //  N,15,2
      _Z2->Z2_MQEXP   := _Z2->Z2_MQEXP   + UZ2->Z2_MQEXP   //  N,15,2
      _Z2->Z2_AQEXP   := iif(_Z2->Z2_MQEXP == 0,0,(_Z2->Z2_QTEXP / _Z2->Z2_MQEXP)*100)

      IF _Z2->Z2_FORMATO # "@"
         IF _Z2->Z2_QTATU == 0
            _Z2->Z2_QTATU := UZ2->Z2_QTATU   //  N,15,2
            nQtdEstq := nQtdEstq + UZ2->Z2_QTATU
         endif
      else
         _Z2->Z2_QTATU  :=  nQtdEstq  //  N,15,2
      endif

      _Z2->Z2_MDFAT   := iif(_Z2->Z2_QTFAT   == 0,0,(_Z2->Z2_VLFAT / _Z2->Z2_QTFAT))
      _Z2->Z2_MDLIQ   := iif(_Z2->Z2_QTFAT   == 0,0,(_Z2->Z2_MBFAT / _Z2->Z2_QTFAT))
      _Z2->Z2_MTMDLIQ := iif(_Z2->Z2_MQFAT   == 0,0,(_Z2->Z2_MVMB  / _Z2->Z2_MQFAT))
      _Z2->Z2_ATMDLIQ := iif(_Z2->Z2_MTMDLIQ == 0,0,(_Z2->Z2_MDLIQ / _Z2->Z2_MTMDLIQ)*100)
      _Z2->Z2_MDMC    := iif(_Z2->Z2_QTFAT   == 0,0,(_Z2->Z2_VLMC  / _Z2->Z2_QTFAT))
      _Z2->Z2_MTMDMC  := iif(_Z2->Z2_MQFAT   == 0,0,(_Z2->Z2_MVMC  / _Z2->Z2_MQFAT))
      _Z2->Z2_AVMDMC  := iif(_Z2->Z2_MTMDMC  == 0,0,(_Z2->Z2_MDMC  / _Z2->Z2_MTMDMC)*100)

      if xMTPRZMD == 0
         _Z2->Z2_PRZMD   := UZ2->Z2_PRZMD   //  N, 3,0
         _Z2->Z2_MTPRZMD := UZ2->Z2_MTPRZMD //  N, 3,0
         _Z2->Z2_DIPRZ   := _Z2->Z2_PRZMD - _Z2->Z2_MTPRZMD
         xMTPRZMD        := UZ2->Z2_MTPRZMD
         xPRZMD          := UZ2->Z2_PRZMD
      endif
      MsUnLock()
      
      DbSelectArea("UZ2")
      If _Z2->Z2_FORMATO == "@"
         DbSkip()
      Else
         DbSkip()
         If xData # UZ2->Z2_DATA .and. !lEmp
            DbSeek("@@"+Dtos(xData))
            lEmp := .T.
         EndIf
      EndIf
   EndDo
   
   xData := xData + 1
   IF !UZ2->(DbSeek("  "+Dtos(xData), .F.)) .OR. (xData > MV_PAR02)
      EXIT
   ENDIF   
EndDo

DbSelectArea("_Z2") // Reposiciona Total
if _Z2->(LastRec()) == 0
   RecLock("_Z2",.T.)
   _Z2->Z2_FORMATO := "@"
   _Z2->Z2_TIPO    := "@"
   MsUnlock("_Z2")
EndIf

DbSeek("@@",.F.)
RecLock("_Z2", .F. )
_Z2->Z2_FORMATO := chr(254)
_Z2->Z2_TIPO    := chr(254)
_Z2->Z2_PRZMD   := xPRZMD  // xPRZMD  /  xDias
_Z2->Z2_MTPRZMD := xMTPRZMD
_Z2->Z2_DIPRZ   := _Z2->Z2_PRZMD - _Z2->Z2_MTPRZMD
MsUnLock()

_Z2->(DbGoTop())
Do while (_Z2->Z2_FORMATO # chr(254)) .AND. !_Z2->(EOF())
   cCh := _Z2->Z2_FORMATO
   sum _Z2->Z2_QTPRD, _Z2->Z2_QTLIB to nQTPRD,nQTLIB while cCh == _Z2->Z2_FORMATO
   _Z2->(DbSeek(cCh))
   Do While (_Z2->Z2_FORMATO == cCh) .AND. !_Z2->(EOF())
      RecLock("_Z2", .F. )
      _Z2->Z2_PCPRD   := iif(nQTPRD == 0,0,(_Z2->Z2_QTPRD / nQTPRD) * 100) // % Producao
      _Z2->Z2_PCLIB   := iif(nQTLIB == 0,0,(_Z2->Z2_QTLIB / nQTLIB) * 100) // % Liberada
      MsUnLock()
      _Z2->(DbSkip())
   Enddo
Enddo
_Z2->(DbGoTop())



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava na tabela temporaria de resumo gerencial os dados de Pedido em ... ³
//³ Carteira coletado na tabela UZ2 para cada classificacao de piso.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

tClsA1 := 0
tClsA2 := 0
tClsA3 := 0
tClsB1 := 0
tClsB2 := 0
tClsB3 := 0
tClsC1 := 0
tClsC2 := 0
tClsC3 := 0

tCls   := 0

DbSelectArea("UZ2")
DbGoTop()
ProcRegua(UZ2->(LastRec())+2)

do while !EOF()
   IncProc("Processando Pedidos em Carteira ...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data no resumo gerencial pertence ao periodo especificado nos parametros. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   IF UZ2->Z2_DATA > MV_PAR02
      UZ2->(DBSKIP())
      LOOP
   ENDIF

   wCls   := UZ2->Z2_FORMATO+UZ2->Z2_TIPO
   wSaldo := UZ2->Z2_QTPED    
   IF wsaldo > 0
      abc:=1
   endif   

/*   do case
      case wCls == "A1";  tClsA1 := tClsA1+wSaldo;  tCls := tCls+wSaldo
      case wCls == "A2";  tClsA2 := tClsA2+wSaldo;  tCls := tCls+wSaldo
      case wCls == "A3";  tClsA3 := tClsA3+wSaldo;  tCls := tCls+wSaldo
      case wCls == "B1";  tClsB1 := tClsB1+wSaldo;  tCls := tCls+wSaldo
      case wCls == "B2";  tClsB2 := tClsB2+wSaldo;  tCls := tCls+wSaldo
      case wCls == "B3";  tClsB3 := tClsB3+wSaldo;  tCls := tCls+wSaldo
      case wCls == "C1";  tClsC1 := tClsC1+wSaldo;  tCls := tCls+wSaldo
      case wCls == "C2";  tClsC2 := tClsC2+wSaldo;  tCls := tCls+wSaldo
      case wCls == "C3";  tClsC3 := tClsC3+wSaldo;  tCls := tCls+wSaldo
   endcase*/
   DbSelectArea("_Z2")
   If DbSeek(UZ2->Z2_FORMATO+UZ2->Z2_TIPO)
      RecLock("_Z2", .F.)
   	  _Z2->Z2_QTPED  := _Z2->Z2_QTPED + UZ2->Z2_QTPED
      MsUnlock()
      tCls := tCls+wSaldo   
   EndIf   
   DbSelectArea("UZ2")
   DbSkip()
enddo

DbSelectArea("_Z2")
DbGotop()
IncProc("Processando Pedidos em Carteira ...")
Do while !Eof()
   	If Z2_FORMATO+Z2_TIPO <> chr(254)+chr(254) 
   		RecLock("_Z2", .F.)
   		_Z2->Z2_QTDISP := _Z2->Z2_QTATU - _Z2->Z2_QTPED
		MsUnlock()
	EndIf	
   	DbSkip()
EndDo   
IncProc("Processando Pedidos em Carteira ...")
if DbSeek(chr(254)+chr(254), .F.)
   RecLock("_Z2", .F.)
   _Z2->Z2_QTPED  := tCls
   _Z2->Z2_QTDISP := _Z2->Z2_QTATU - _Z2->Z2_QTPED
   DbUnlock()
endif
DbSelectArea("UZ2")
Set filter to      
DbSelectArea("_Z2")
Return