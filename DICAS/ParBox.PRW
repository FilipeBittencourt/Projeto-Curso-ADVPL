#Include 'TOTVS.CH'
#Include "TopConn.ch"

//U_ParBox
User Function ParBox()

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  ParBox5()

RETURN

Static Function ParBox1()

  Local aParamBox := {}
  Local oJSObj    := JsonObject():New()
  Local cSQL      := ""
  Local cQry      := GetNextAlias()
  Local nSoma     := 0
  Local aRet      := {}
  Local aFINA100  := {}
  Local cError    := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})

  Private lMsErroAuto    := .F.

  If Select("SX6") <= 0
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  if U_UDiaUtil()

    aAdd(aParamBox,{1,"Banco",SPACE(TamSX3("A6_COD")[01]),"","","SA6","",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Agencia",SPACE(TamSX3("A6_AGENCIA")[01]),"","","",".F.",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Conta",SPACE(10),"","","",".F.",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Data Inicio"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Data Fim"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data

    If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

      oJSObj["Banco"]    := AllTrim(aRet[1])
      oJSObj["Agencia"]  := AllTrim(aRet[2])
      oJSObj["Conta"]    := AllTrim(aRet[3])
      oJSObj["DtInicio"] := AllTrim(DTOS(aRet[4]))
      oJSObj["DtFim"]    := AllTrim(DTOS(aRet[5]))


      //Realiza a baixa de tarifa diaria quando for banco do brasil

      cSQL := "SELECT top 5 ZK4_VLTAR , ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA, R_E_C_N_O_ "
      cSQL += " FROM " + RetSQLName("ZK4")
      cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
      cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
      cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
      cSQL += " AND ZK4_TIPO = 'R' "
      cSQL += " AND ZK4_STATUS = '1' " // Integrado
      cSQL += " AND D_E_L_E_T_ = ''	"
      cSQL += " AND ZK4_BANCO  = "+ValToSQL(oJSObj["Banco"])
      cSQL += " AND ZK4_AGENCI = "+ValToSQL(oJSObj["Agencia"])
      cSQL += " AND ZK4_CONTA = "+ValToSQL(oJSObj["Conta"])
      cSQL += " AND ZK4_DATA BETWEEN "+ValToSQL(oJSObj["DtInicio"])+" AND "+ValToSQL(oJSObj["DtFim"])

      TcQuery cSQL New Alias (cQry)

      While !(cQry)->(Eof())
        nSoma := nSoma + (cQry)->ZK4_VLTAR
        (cQry)->(DbSkip())
      EndDo

      (cQry)->(DbGoTop())

      If  nSoma > 0

        aFINA100 := {;
          {"E5_DATA"      , dDataBase                   ,Nil},;
          {"E5_MOEDA"     , "M1"                        ,Nil},;
          {"E5_VALOR"     , nSoma                       ,Nil},;
          {"E5_NATUREZ"   , "2915"                      ,Nil},;
          {"E5_BANCO"     , (cQry)->ZK4_BANCO           ,Nil},;
          {"E5_AGENCIA"   , (cQry)->ZK4_AGENCI          ,Nil},;
          {"E5_CONTA"     , (cQry)->ZK4_CONTA           ,Nil},;
          {"E5_BENEF"     , ""                          ,Nil},;
          {"E5_HISTOR"    , "TAR. ENVIO COBRANCA DO PERIODO "+CVALTOCHAR(oJSObj["DtInicio"])+" a "+CVALTOCHAR(oJSObj["DtFim"]) ,Nil}}

        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)


        If !lMsErroAuto

          While !(cQry)->(Eof())

            RecLock('ZK4', .F.)
            ZK4_STATUS := '2' // Processado
            ZK4->(MsUnlock())
            (cQry)->(DbSkip())

          EndDo

          FwAlertSuccess('Tarifas geradas com sucesso.','SUCESSO - BAF004')

        Else

          ErrorBlock(oError)
          cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
          FwAlertError(cError,'Error')

        EndIf

      EndIf

      (cQry)->(DbCloseArea())

    Endif

    FreeObj(oJSObj)

  EndIf

RETURN

//U_ParBox2
Static Function ParBox2()


  Local oJSObj    := JsonObject():New()
  Local aRet      := {}
  Private cTT     := ""
  Private aParamBox := {}

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  aAdd(aParamBox,{1,"Cod Vend.",SPACE(TamSX3("A3_COD")[01]),"","U_TPARBOX2('01')","SA3","",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"CGC Vend",SPACE(TamSX3("A3_CGC")[01]),"","","",".F.",0,.T.}) // Tipo caractere
  //aAdd(aParamBox,{1,"Conta",SPACE(10),"","","",".F.",0,.T.}) // Tipo caractere
  //aAdd(aParamBox,{1,"Data Inicio"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
  //aAdd(aParamBox,{1,"Data Fim"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
  //aAdd(::aParam, {1, "Natureza", ::cNatureza, "@!", "U_BAF031A('06')", "SED", ".T.", 50, .T.})
  If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

    oJSObj["Banco"]    := AllTrim(aRet[1])
    oJSObj["Agencia"]  := AllTrim(aRet[2])
    oJSObj["Conta"]    := AllTrim(aRet[3])
    //oJSObj["DtInicio"] := AllTrim(DTOS(aRet[4]))
    //oJSObj["DtFim"]    := AllTrim(DTOS(aRet[5]))
  ENDIF

Return

Static Function TPARBOX2(cPar)

  Local lRet    := .T.
  &("MV_PAR02") := "0123456"

RETURN lRet


Static Function ParBox3()

  Local oJSObj    := JsonObject():New()
  Local aRet      := {}
  Private cTT     := ""
  Private aParamBox := {}

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  aAdd(aParamBox,{1,"Cod Vend.",SPACE(TamSX3("A3_COD")[01]),"","U_TPARBOX2('01')","SA3","",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"CGC Vend",SPACE(TamSX3("A3_CGC")[01]),"","","",".F.",0,.T.}) // Tipo caractere

  If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

    oJSObj["CodVend"]  := AllTrim(aRet[1])
    oJSObj["CGCVend"]  := AllTrim(aRet[2])

  ENDIF

Return


Static Function ParBox4()
  Local aRet := {}
  Local aParamBox := {}
  Local nI := 0


  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf
  /*
  --------------------------------------------------------------
  Abaixo está a montagem do vetor que será passado para a função
  --------------------------------------------------------------

            Tipo 1 -> MsGet()
            [2]-Descricao
            [3]-String contendo o inicializador do campo
            [4]-String contendo a Picture do campo
            [5]-String contendo a validacao
            [6]-Consulta F3
            [7]-String contendo a validacao When
            [8]-Tamanho do MsGet
            [9]-Flag .T./.F. Parametro Obrigatorio ?

*/

  aAdd(aParamBox,{1,"Banco",SPACE(TamSX3("A6_COD")[01]),"","","SA6","",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"Agencia",SPACE(TamSX3("A6_AGENCIA")[01]),"","","",".F.",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"Conta",SPACE(10),"","","",".F.",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"Data Inicio"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
  aAdd(aParamBox,{1,"Data Fim"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data

  If ParamBox(aParamBox,"Teste Parâmetros...",@aRet)
    For i:=1 To Len(aRet)
      MsgInfo(aRet[nI],"Opção escolhida")
    Next
  Endif

Return



// Função exemplo utilizando a função ParamBox()
//----------------------------------------------------------
Static Function ParBox5()
  Local aRet := {}
  Local aParamBox := {}
  Local aCombo := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
  Local i := 0

  Private cCadastro := "xParambox"

// --------------------------------------------------------------
// Abaixo está a montagem do vetor que será passado para a função
// --------------------------------------------------------------

  aAdd(aParamBox,{1,"Produto",Space(15),"","","SB1","",0,.F.}) // Tipo caractere

  aAdd(aParamBox,{1,"Valor",0,"@E 9,999.99","mv_par02>0","","",20,.F.}) // Tipo numérico

  aAdd(aParamBox,{1,"Data"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
// Tipo 1 -> MsGet()
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-Consulta F3
//           [7]-String contendo a validacao When
//           [8]-Tamanho do MsGet
//           [9]-Flag .T./.F. Parametro Obrigatorio ?

  aAdd(aParamBox,{2,"Informe o mês",1,aCombo,50,"",.F.})
// Tipo 2 -> Combo
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do combo
//           [4]-Array contendo as opcoes do Combo
//           [5]-Tamanho do Combo
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?
// Cuidado, há um problema nesta opção quando selecionado a 1ª opção.

  aAdd(aParamBox,{3,"Mostra deletados",1,{"Sim","Não"},50,"",.F.})
// Tipo 3 -> Radio
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do Radio
//           [4]-Array contendo as opcoes do Radio
//           [5]-Tamanho do Radio
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

  aAdd(aParamBox,{4,"Marca todos ?",.F.,"Marque todos se necessário for.",90,"",.F.})
// Tipo 4 -> Say + CheckBox
//           [2]-Descricao
//           [3]-Indicador Logico contendo o inicial do Check
//           [4]-Texto do CheckBox
//           [5]-Tamanho do Radio
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

  aAdd(aParamBox,{5,"Marca todos ?",.F.,50,"",.F.})
// Tipo 5 -> Somente CheckBox
//           [2]-Descricao
//           [3]-Indicador Logico contendo o inicial do Check
//           [4]-Tamanho do Radio
//           [5]-Validacao
//           [6]-Flag .T./.F. Parametro Obrigatorio ?

  aAdd(aParamBox,{6,"Buscar arquivo",Space(50),"","","",50,.F.,"Todos os arquivos (*.*) |*.*"})
// Tipo 6 -> File
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-String contendo a validacao When
//           [7]-Tamanho do MsGet
//           [8]-Flag .T./.F. Parametro Obrigatorio ?
//           [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
//           [10]-Diretorio inicial do cGetFile
//           [11]-Número relativo a visualização, podendo ser por diretório ou por arquivo (0,1,2,4,8,16,32,64,128)

  aAdd(aParamBox,{7,"Monte o filtro","SX5","X5_FILIAL==xFilial('SX5')"})
// Tipo 7 -> Montagem de expressao de filtro
//           [2]-Descricao
//           [3]-Alias da tabela
//           [4]-Filtro inicial

  aAdd(aParamBox,{8,"Digite a senha",Space(15),"","","","",80,.F.})
// Tipo 8 -> MsGet Password
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-Consulta F3
//           [7]-String contendo a validacao When
//           [8]-Tamanho do MsGet
//           [9]-Flag .T./.F. Parametro Obrigatorio ?

  aAdd(aParamBox,{9,"Texto aleatório, apenas demonstrativo.",150,7,.T.})
// Tipo 9 -> Somente uma mensagem, formato de um título
//           [2]-Texto descritivo
//           [3]-Largura do texto
//           [4]-Altura do texto
//           [5]-Valor lógico sendo: .T. => fonte tipo VERDANA e .F. => fonte tipo ARIAL

  aAdd(aParamBox,{10,"Cliente",Space(6),"SA1",40,"C",6,".T."})
// Tipo 10 -> Range de busca
//            [2] = Título
//            [3] = Inicializador padrão
//            [4] = Consulta F3
//            [5] = Tamanho do GET
//            [6] = Tipo do dado, somente (C=caractere e D=data)
//            [7] = Tamanho do espaço
//            [8] = Condição When

  aAdd(aParamBox,{11,"Informe o motivo","",".T.",".T.",.T.})
// Tipo 11 -> MultiGet (Memo)
//            [2] = Descrição
//            [3] = Inicializador padrão
//            [4] = Validação
//            [5] = When
//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)

// Parametros da função Parambox()
// -------------------------------
// 1 - < aParametros > - Vetor com as configurações
// 2 - < cTitle >      - Título da janela
// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
// 4 - < bOk >         - Code block para validar o botão Ok
// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
// 6 - < lCentered >   - Centralizar a janela
// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
//10 - < cLoad >       - Nome do perfil se caso for carregar
//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
//12 - < lStaticSave >   - Configuração por usuário

// Caso alguns parâmetros para a função não seja passada será considerado DEFAULT as seguintes abaixo:
// DEFAULT bOk   := {|| (.T.)}
// DEFAULT aButtons := {}
// DEFAULT lCentered := .T.
// DEFAULT nPosX  := 0
// DEFAULT nPosY  := 0
// DEFAULT cLoad     := ProcName(1)
// DEFAULT lCanSave := .T.
// DEFAULT lStaticSave := .F.

  If ParamBox(aParamBox,"Teste Parâmetros...",@aRet)
    For i:=1 To Len(aRet)
      MsgInfo(aRet[i],"Opção escolhida")
    Next
  Endif

Return

