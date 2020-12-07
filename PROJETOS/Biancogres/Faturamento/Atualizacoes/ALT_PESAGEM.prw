#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

User Function ALT_PESAGEM()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALT_PESAGEM       ³Microsiga           º Data ³  04/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PERMITE A ALTERACAO DA PLACA E SEQUENCIA                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 8 - R4                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

SetPrvt("oFont1","oDlg1","oGrp1","oSay2","oSay1","oCBox1","oGet1","oSBtn1","oSBtn2")

Private cCPLACA := SUBSTR(Z11->Z11_PCAVAL,1,3) + "-" + SUBSTR(Z11->Z11_PCAVAL,4,4) //Space(8)
Private cCombo 	:= IIF(Z11->Z11_MERCAD = 1,"ENTREGA","RETIRADA")
PRIVATE cTRAN   := IIF(Z11->Z11_CODTRA = "",SPACE(6),Z11->Z11_CODTRA)
PRIVATE cLOJA   := IIF(Z11->Z11_LJTRAN = "",SPACE(2),Z11->Z11_LJTRAN)
PRIVATE cDESC   := IIF(Z11->Z11_CODTRA = "",SPACE(100),ALLTRIM(Posicione("SA2",1,xFilial("SA2")+Z11->Z11_CODTRA,"A2_NOME")))

oFont1     		:= TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
oDlg1      		:= MSDialog():New( 095,232,392,532,"ALTERAÇÃO DE PLACA",,,.F.,,,,,,.T.,,,.T. )
oGrp1      		:= TGroup():New( 008,008,116,140,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay2      		:= TSay():New( 049,012,{||"SEQUENCIA"},oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)
oSay1      		:= TSay():New( 024,012,{||"PLACA"},oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCombo 			:= TComboBox():New(048,068,{|u|if(PCount()>0,cCombo:=u,cCombo)},{"ENTREGA","RETIRADA"},068,012,oGrp1,,,,,,.T.,oFont1,,,,,,,,'cCombo')

oGet1      		:= TGet():New( 024,068,{|u| If(PCount()>0,cCPLACA:=u,cCPLACA)},oGrp1,068,010,"@! AAA-9999",,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCPLACA",,)

oSay2      		:= TSay():New( 070,012,{||"TRANSPÓRTADORA"},oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)

oGet2      		:= TGet():New( 080,012,{|u| If(PCount()>0,cTRAN:=u,cTRAN)},oGrp1,040,008,,,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA2","cTRAN",,)
oGet2:bVALID 	:= {|| CCTRANS("FORNE")}
oGet3      		:= TGet():New( 080,100,{|u| If(PCount()>0,cLOJA:=u,cLOJA)},oGrp1,020,008,,,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cLOJA",,)
oGet3:bVALID 	:= {|| CCTRANS("LOJA")}
oGet4      		:= TGet():New( 100,012,{|u| If(PCount()>0,cDESC:=u,cDESC)},oGrp1,100,008,,,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cDESC",,)

oSBtn1          := SButton():New( 124,012,13,{|| PES_GRAVA() },oDlg1,,"", )
oSBtn2          := SButton():New( 124,112,02,{|| oDlg1:End() } ,oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ CCTRANS  ¦ Autor ¦                       ¦ Data ¦   .  .   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Valida Transportadora informada                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
STATIC FUNCTION CCTRANS(SSTATUS)

IF ALLTRIM(cTRAN) = ""
	RETURN
END IF

IF SSTATUS = "FORNE"
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+cTRAN+'01'))
		cLOJA := '01'
		cDESC := SA2->A2_NOME
		oDlg1:Refresh()
	Else
		If !Empty(cTRAN)
			MsgINFO("Transportadora não cadastrada")
			Return(.F.)
		EndIf
		cTRAN := Space(6)
	EndIf
ELSE
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+cTRAN+cLOJA))
		cDESC := SA2->A2_NOME
		oDlg1:Refresh()
	Else
		If !Empty(cTRAN)
			MsgINFO("Transportadora não cadastrada")
			Return(.F.)
		EndIf
		cTRAN := Space(6)
	EndIf
END IF

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ PES_GRAVA  ¦ Autor ¦                     ¦ Data ¦   .  .   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ ROTINA QUE GRAVA A NOVA PLACA E A PESAGEM                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function PES_GRAVA()

oDlg1:End()

CSQL := " SELECT ISNULL(COUNT(Z11_PCAVAL),0) AS QUANT
CSQL += "   FROM " + RetSqlName("Z11")
CSQL += "  WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
CSQL += "    AND Z11_PCAVAL = '"+Substr(cCPLACA,1,3) + Substr(cCPLACA,5,4)+"'
CSQL += "    AND Z11_DATAIN = '"+dtos(dDataBase)+"'
CSQL += "    AND D_E_L_E_T_ = ' '
If ChkFile("C_TESTE")
	dbSelectArea("C_TESTE")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "C_TESTE" NEW

// Verifica se existe uma placa em aberto no sistema para não criar uma nova ocorrência antes de fechar a ocorrência existente.
WX004 := " SELECT COUNT(*) CONTAD
WX004 += "   FROM "+RetSqlName("Z11")
WX004 += "  WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
WX004 += "    AND Z11_MERCAD = '2'
WX004 += "    AND NOT(Z11_PESOIN <> 0 AND Z11_PESOSA <> 0)
WX004 += "    AND Z11_PCAVAL = '"+Substr(cCPLACA,1,3)+Substr(cCPLACA,5,4)+"'
WX004 += "    AND Z11_PESAGE <> '"+Z11->Z11_PESAGE+"'
WX004 += "    AND D_E_L_E_T_ = ' '
WXIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,WX004),'WX04',.T.,.T.)
dbSelectArea("WX04")
dbGoTop()
If WX04->CONTAD == 0                         // Caso não exista Ticket em aberto para a placa, permite alterar
	**********************************************************************************************************
	
	dbSelectArea("Z11")
	RecLock('Z11',.F.)
	Z11->Z11_PCAVAL := Substr(cCPLACA,1,3) + Substr(cCPLACA,5,4)
	Z11->Z11_MERCAD	:= IIF(cCombo = "ENTREGA",1,2)
	Z11->Z11_SEQB   := IIF(cCombo = "ENTREGA","",LTRIM(STR(IIF(C_TESTE->QUANT=0,1,C_TESTE->QUANT + 1))))
	Z11->Z11_CODTRA := cTRAN
	Z11->Z11_LJTRAN := cLOJA
	MsUnLock()
	
Else                                         // Caso exista Ticket em aberto para a placa, não permite alterar
	**********************************************************************************************************
	
	zpTkts := ""
	ZT004 := " SELECT Z11_PESAGE
	ZT004 += "   FROM "+RetSqlName("Z11")
	ZT004 += "  WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	ZT004 += "    AND Z11_MERCAD = '2'
	ZT004 += "    AND NOT(Z11_PESOIN <> 0 AND Z11_PESOSA <> 0)
	ZT004 += "    AND Z11_PCAVAL = '"+Substr(cCPLACA,1,3)+Substr(cCPLACA,5,4)+"'
	ZT004 += "    AND Z11_PESAGE <> '"+Z11->Z11_PESAGE+"'
	ZT004 += "    AND D_E_L_E_T_ = ' '
	ZTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZT004),'ZT04',.T.,.T.)
	dbSelectArea("ZT04")
	dbGoTop()
	While !Eof()
		
		zpTkts := ZT04->Z11_PESAGE + ", "
		
		dbSelectArea("ZT04")
		dbSkip()
		
	End
	
	ZT04->(dbCloseArea())
	Ferase(ZTIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZTIndex+OrdBagExt())          //indice gerado
	
	Aviso('Alteração de Placa!!!','Esta Placa já está sendo usada em outro ticket que não foi finalizado. Não será permitido efetuar a alteração. Favor verificar o ticket: ' + zpTkts, {'Ok'})
	
EndIf

WX04->(dbCloseArea())
Ferase(WXIndex+GetDBExtension())     //arquivo de trabalho
Ferase(WXIndex+OrdBagExt())          //indice gerado

Return
