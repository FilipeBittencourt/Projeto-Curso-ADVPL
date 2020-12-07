#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIAGPE001 º Autor ³ Julio Almeida      º Data ³  27/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastros Transferencias - SRE                             º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPE -  Gestao de Pessoal                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIAGPE001()

Local cArq,cInd
Local aStru
Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "Transferencias"
Local cPict        := ""
Private aOrd       := {"NOME","CCUSTO+NOME"}
Private CbTxt      := ""

Private lEnd       := .F.
Private lAbortPrint:= .F.
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "BIAGPE001" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cPerg      := "BIBGPE001"
Private titulo     := "Tranferencias"
Private li         := 80
//Local Cabec1       := "Num.   Nome do Empregado              Funcao               N.CP    Serie Horarios                                           V.Fiscal"
Private Cabec1 	   := ""
Private Cabec2     := ""
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private imprime      := .T.
Private wnrel      := "BIAGPE001" // Coloque aqui o nome do arquivo usado para impressao em disco
     
//|Atualiza perguntas |
	SFP001()
					   
// pegar dados da empresa
nRec := SM0->(RecNo())
SM0->(dbSeek(SM0->M0_CODIGO))
cEmp  := SM0->M0_NOMECOM
cCNPJ := SM0->M0_CGC        
cCab1 := "             Origem..........................   Destino........................."
cCab2 := "  Data       Empr/Fil  CCusto       Matricula   Empr/Fil  CCusto       Matricula"
SM0->(dbGoTo(nRec))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                  
wnrel := SetPrint("SRA",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"SRA")

If nLastKey == 27
   Return
Endif

pergunte(cPerg,.F.)  

cFilDe	 	:= mv_par01
cFilAte 	:= mv_par02
cMatDe		:= mv_par03
cMatAte 	:= mv_par04
cCCDe 		:= mv_par05
cCCAte 		:= mv_par06
cSituac 	:= Upper(mv_par07)
cCateg 		:= Upper(mv_par08)
nQuebra 	:= mv_par09
cDataDe   := mv_par10
cDataAte  := mv_par11

nTipo := If(aReturn[4]==1,15,18)

MsAguarde({|| RunReport(Cabec1,Cabec2,Titulo,li) },"Imprimindo",,.T.)
Return

//
Static Function RunReport(Cabec1,Cabec2,Titulo,li)
Local nRec,cFil, nTra

dbSelectArea("SRA") // RA_MAT
if aReturn[8]==1
  dbSetOrder(3)
else
  dbSetOrder(8)
endif
           
SRA->(dbSeek(cFilDe,.T.)) // Posiciona no 1o.reg. satisfatorio
OldFilial := SRA->RA_FILIAL
While !SRA->(EOF()) .And. SRA->RA_FILIAL <= cFilAte

  If Interrupcao(@lAbortPrint)
    @li,00 PSAY "*** CANCELADO PELO OPERADOR ***"
    Exit
  Endif
  
  MsProcTxt(SRA->RA_NOME)
  If SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte
    SRA->(dbSkip())
    Loop
  Endif
  If SRA->RA_CC < cCCDe .Or. SRA->RA_CC > cCCAte
    SRA->(dbSkip())
    Loop
  Endif
  If !(SRA->RA_SITFOLH $cSituac)
    SRA->(dbSkip())
    Loop
  Endif
  If !(SRA->RA_CATFUNC $cCateg)
    SRA->(dbSkip())
    Loop
  Endif
  
  aTransf	:=	{}
  aTraFE	:=	{}
  fTransf(@aTransf,,,,,,,.T.)

  For nTra := 1 To Len(aTransf)
    if (aTransf[nTra,7] >= cDataDe).And.(aTransf[nTra,7] <= cDataAte)
      aAdd(aTraFE,{aTransf[nTra,1] ,; // Empresa De
                   aTransf[nTra,2] ,; // Filial + Matricula De
		           		 aTransf[nTra,3] ,; // Centro de Custo De
				   				 aTransf[nTra,4] ,; // Empresa Para
				   				 aTransf[nTra,5] ,; // Filial + Matricula Para
				   				 aTransf[nTra,6] ,; // Centro de Custo Para
				   				 aTransf[nTra,7] ,; // Data da Transferencia
				     	     } )
    EndIf
  Next nTra    
  
  if Len(aTraFE)>0
    /*if SRA->RA_FILIAL = "20"
      cDebug := ""
    endif*/
  
    // e possivel melhorar a logica aqui: o seek no SM0 esta em dois lugares, mas executa apenas uma vez
    if (li > 55) .or. ( (SRA->RA_FILIAL <> OldFilial).and.(nQuebra == 1) )
      li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      fMeuCabec(@li)                
      // pega a descr da filial
      nRec := SM0->(RecNo())
      SM0->(dbSeek(SM0->M0_CODIGO+SRA->RA_FILIAL))
      cFil := SM0->M0_FILIAL
      SM0->(dbGoTo(nRec))     
      //   
      if SRA->RA_FILIAL <> OldFilial
        OldFilial := SRA->RA_FILIAL
      endif
      
      @++li,00 PSAY "FILIAL: " + SRA->RA_FILIAL + ' - ' + cFil
      li++
    Endif
    
    if SRA->RA_FILIAL <> OldFilial
     OldFilial := SRA->RA_FILIAL 
     if nQuebra==2
       // pega a descr da filial
       nRec := SM0->(RecNo())
       SM0->(dbSeek(SM0->M0_CODIGO+SRA->RA_FILIAL))
       cFil := SM0->M0_FILIAL
       SM0->(dbGoTo(nRec))     
       //
       li++
       @++li,00 PSAY "FILIAL: " + SRA->RA_FILIAL + ' - ' + cFil
       li++
     endif
    endif
           
  
    @++li,00 PSAY SRA->RA_NOME
    for nTra := 1 to Len(aTraFE)
      @++li,02 PSAY DTOC(aTraFE[nTra,7]) + ;
        "   "    + aTraFE[nTra,1] + " / " + SubStr(aTraFE[nTra,2],1,2) + "   " + aTraFE[nTra,3] + "    " + SubStr(aTraFE[nTra,2],3,6) + ;
        "      " + aTraFE[nTra,4] + " / " + SubStr(aTraFE[nTra,5],1,2) + "   " + aTraFE[nTra,6] + "    " + SubStr(aTraFE[nTra,5],3,6)
    Next nTra  
  endif

  SRA->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return        

Static Function fMeuCabec(li)
@++li,00 PSAY "EMPREGADOR: "+cEmp+Space(4) +"CNPJ: "+Transform(cCNPJ,"@R 99.999.999/9999-99")
@++li,00 PSAY Replicate("-",132)
@++li,00 PSAY cCab1
@++li,00 PSAY cCab2
@++li,00 PSAY Replicate("-",132)
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³AjustaSX1 ³ Autor ³Ricardo Berti          ³ Data ³11/11/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Ajusta Perguntas 											³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function SFP001()

Local aArea		:= GetArea()

	PutSx1(cPerg, "01", "Filial De?", "", "", "mv_ch1", "C", FWGETTAMFILIAL, 00, 00, "G", "", "SM0", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a Filial inicial para ser      "    ,;
	"utilizada no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")
	
	PutSx1(cPerg, "02", "Filial Ate?", "", "", "mv_ch2", "C", FWGETTAMFILIAL, 00, 00, "G", "NaoVazio()", "SM0", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a Filial Final para ser       "    ,;
	"utilizada no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")
	PutSx1(cPerg, "03", "Matricula De?", "", "", "mv_ch3", "C", 06, 00, 00, "G", "", "SRA", "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a Matricula inicial para ser      "    ,;
	"utilizada no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")
	
	PutSx1(cPerg, "04", "Matricula Ate?", "", "", "mv_ch4", "C", 06, 00, 00, "G", "NaoVazio()", "SRA", "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe a Matricula Final para ser       "    ,;
	"utilizada no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")	
	PutSx1(cPerg, "05", "Centro de Custo De?", "", "", "mv_ch5", "C", 09, 00, 00, "G", "", "CTT", "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe o Centro de Custo inicial para ser      "    ,;
	"utilizado no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")
	
	PutSx1(cPerg, "06", "Centro de Custo Ate?", "", "", "mv_ch6", "C", 09, 00, 00, "G", "NaoVazio()", "CTT", "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {;
	"Informe o Centro de Custo Final para ser       "    ,;
	"utilizado no filtro de todas as 	  "    ,;
	"consultas.                            "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")	
	PutSx1(cPerg,"07","Situações  a Impr. ?	","","","mv_ch7","C",05,0,1,"G","fSituacao()","","","","MV_PAR07","","","","","","","","","","","","","","","","",{;
	"Informe as Situaçoes a imprimir                ",;
	"                                  	   "   ,;
	"                                      "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")	
	PutSx1(cPerg,"08","Categorias a Impr. ?	","","","mv_ch8","C",10,0,1,"G","fCategoria()","","","","MV_PAR08","","","","","","","","","","","","","","","","",{;
	"Informe as Categorias a imprimir               ",;
	"                                  	   "   ,;
	"                                      "   ,;
	"                                      "   ,;
	"                                      "   ,;
												},{},{},"")	
	PutSx1(cPerg,"09","Filial Quebra Pg ?","","","mv_ch9","N",01,0,2,"C","","","","","MV_PAR09","Sim","","","","Nao","","","","","","","","","","","",{},{},{},"")
	PutSx1(cPerg,"10","Data De       	","","","mv_cha","D",08,0,0,"G","","",,,"MV_PAR10","","","",,"","","","","","","","","","","","",{"Data Emissão inicial"},{},{},"")                                                       
	PutSx1(cPerg,"11","Data Ate      	","","","mv_chb","D",08,0,0,"G","NaoVazio()","","","","MV_PAR11","","","","","","","","","","","","","","","","",{"Data Emissão final"},{},{},"")

RestArea(aArea)

Return( Nil )

