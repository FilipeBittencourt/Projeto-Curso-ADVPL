#Include 'Protheus.ch'
#Include 'Report.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} BFATRE04
Relatório de Notas Fiscais não classificadas

@author Augusto Pontin
@since 30.01.15
@version 1.00

/*/

User Function BFATRE04()

  Local oReport
  Local cPerg	:= "BFATRE04"

  //|Cria as Perguntas |
  BFATRE04A(cPerg)

  Pergunte(cPerg, .F.)
  oReport := ReportDef()
  oReport:SetLandscape()
  oReport:PrintDialog()

Return()


Static Function ReportDef()
  Local oReport
  Local oSecCE

  oReport := TReport():New("BFATRE04","Relatório de Notas Fiscais não classificadas","BFATRE04",{|oReport| PrintReport(oReport)},"Relatório de Notas Fiscais não classificadas")

  oSecCE := TRSection():New(oReport,"CE","ZZZ")

  TRCell():New(oSecCE,"ZZZ_FILIAL","ZZZ","Filial",, 10)
  TRCell():New(oSecCE,"ZZZ_TIPO","ZZZ",,, 10)
  TRCell():New(oSecCE,"ZZZ_DOC","ZZZ")
  TRCell():New(oSecCE,"ZZZ_SERIE","ZZZ",,,7)
  TRCell():New(oSecCE,"NATUREZA",,"Nat.Operacao",,30)
  TRCell():New(oSecCE,"ZZZ_STATUS","ZZZ",,,20)
  TRCell():New(oSecCE,"ZZZ_EMISNF","ZZZ",,,15)
  TRCell():New(oSecCE,"ZZZ_CNPJ","ZZZ",,,16)
  TRCell():New(oSecCE,"ZZZ_NOEMIT","ZZZ")
  TRCell():New(oSecCE,"ZZZ_CHAVE","ZZZ")
  TRCell():New(oSecCE,"ZZZ_VLDOC","ZZZ")

  TRFunction():New(oSecCE:Cell("ZZZ_VLDOC"),NIL,"SUM",,NIL,NIL,NIL,.F.,.T.)
  TRFunction():New(oSecCE:Cell("ZZZ_DOC"),NIL,"COUNT",,NIL,NIL,NIL,.F.,.T.)

Return oReport

Static Function PrintReport(oReport)

  Local oSecCE 	:= oReport:Section(1)

  oSecCE:BeginQuery()

  StaticCall(PTX0017,Painel1, "RELATORIO")

  oSecCE:EndQuery()

  __TRB->(DbGoTop())

  oSecCE:Init()

  dbSelectArea("ZZZ")
  ZZZ->( dbSetOrder(1) )

  While !oReport:Cancel() .And. !__TRB->(EoF())

    oReport:IncMeter()

    If oReport:Cancel()
      Exit
    EndIf

    ZZZ->( dbGoTo(__TRB->RECNO) )

    //|Busca a natureza da operacao |
    cNatureza   := StaticCall(PTXR003,fGetNat, ZZZ->ZZZ_XML)

    oSecCE:Cell("ZZZ_FILIAL"):SetValue(__TRB->ZZZ_FILIAL)
    oSecCE:Cell("ZZZ_TIPO"):SetValue(IIf(__TRB->ZZZ_TIPO=="1","NF-e","CT-e"))
    oSecCE:Cell("ZZZ_DOC"):SetValue(__TRB->ZZZ_DOC)
    oSecCE:Cell("ZZZ_SERIE"):SetValue(__TRB->ZZZ_SERIE)
    oSecCE:Cell("NATUREZA"):SetValue(Upper(cNatureza))
    oSecCE:Cell("ZZZ_STATUS"):SetValue(X3Combo("ZZZ_STATUS", __TRB->ZZZ_STATUS))
    oSecCE:Cell("ZZZ_EMISNF"):SetValue(StoD(__TRB->ZZZ_EMISNF))
    oSecCE:Cell("ZZZ_CNPJ"):SetValue(__TRB->ZZZ_CNPJ)
    oSecCE:Cell("ZZZ_NOEMIT"):SetValue(__TRB->ZZZ_NOEMIT)
    oSecCE:Cell("ZZZ_CHAVE"):SetValue(__TRB->ZZZ_CHAVE)
    oSecCE:Cell("ZZZ_VLDOC"):SetValue(__TRB->ZZZ_VLDOC)
    oSecCE:PrintLine()

    __TRB->(dbSkip())

  EndDo

  oSecCE:Finish()

Return

Static Function BFATRE04A(cPerg)

  Local aRegs		:= {}
  Local aHelp		:= {}

  aAdd(aRegs,{"Emissao De ?"	  	 , "", "",  "MV_CH1", "D",TamSx3("ZZZ_EMISNF")[1], TamSx3("ZZZ_EMISNF")[2], 0, "G", ""/*10*/, "MV_PAR01", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Emissao Ate ?"	  	 , "", "",  "MV_CH2", "D",TamSx3("ZZZ_EMISNF")[1], TamSx3("ZZZ_EMISNF")[2], 0, "G", ""/*10*/, "MV_PAR02", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Cnpj Fornec. De ?"	 , "", "",  "MV_CH3", "C",TamSx3("ZZZ_CNPJ")[1], TamSx3("ZZZ_CNPJ")[2], 0, "G", ""/*10*/, "MV_PAR03", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Cnpj Fornec. Ate ?" , "", "",  "MV_CH4", "C",TamSx3("ZZZ_CNPJ")[1], TamSx3("ZZZ_CNPJ")[2], 0, "G", ""/*10*/, "MV_PAR04", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Chave De ?"	  	 , "", "",  "MV_CH5", "C",TamSx3("ZZZ_CHAVE")[1], TamSx3("ZZZ_CHAVE")[2], 0, "G", ""/*10*/, "MV_PAR05", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", ""    , "ZZZ", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Chave Ate ?"	  	 , "", "",  "MV_CH6", "C",TamSx3("ZZZ_CHAVE")[1], TamSx3("ZZZ_CHAVE")[2], 0, "G", ""/*10*/, "MV_PAR06", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "" , "ZZZ", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Filial De ?"	  	 , "", "",  "MV_CH7", "C",TamSx3("ZZZ_FILIAL")[1], TamSx3("ZZZ_FILIAL")[2], 0, "G", ""/*10*/, "MV_PAR07", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "XM0", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Filial Ate ?"	  	 , "", "",  "MV_CH8", "C",TamSx3("ZZZ_FILIAL")[1], TamSx3("ZZZ_FILIAL")[2], 0, "G", ""/*10*/, "MV_PAR08", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "" , "", "", "XM0", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"NF De ?"	  	     , "", "",  "MV_CH9", "C",TamSx3("ZZZ_DOC")[1], TamSx3("ZZZ_DOC")[2], 0, "G", ""/*10*/, "MV_PAR09", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"NF Ate ?"	  	     , "", "",  "MV_CHA", "C",TamSx3("ZZZ_DOC")[1], TamSx3("ZZZ_DOC")[2], 0, "G", ""/*10*/, "MV_PAR10", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "" , "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Serie De ?"	  	 , "", "",  "MV_CHB", "C",TamSx3("ZZZ_SERIE")[1], TamSx3("ZZZ_SERIE")[2], 0, "G", ""/*10*/, "MV_PAR11", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
  aAdd(aRegs,{"Serie Ate ?"	  	 , "", "",  "MV_CHC", "C",TamSx3("ZZZ_SERIE")[1], TamSx3("ZZZ_SERIE")[2], 0, "G", ""/*10*/, "MV_PAR12", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })


  oPTGENC01 := PTGENC01():New()
  oPTGENC01:AJUSTASX1( cPerg, aRegs )

Return
