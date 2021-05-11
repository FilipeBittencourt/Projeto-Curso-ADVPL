using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Facile.Financeiro.BoletoNetCore
{
    public class ArquivoRetorno
    {
        public class RegistroRetorno
        {
            public string TipoRegistro { get; set; }
            public string TipoSegmento { get; set; }

            public Boleto Boleto { get; set; }  //Objeto usado para a estrutura de retorno de cobrança - mesmo do registro

            public Pagamento Pagamento { get; set; } //Objeto usado para a estrutura de retorno de pagamentos
        }

        public IBanco Banco { get; set; }
        public TipoArquivo TipoArquivo { get; set; }
        public Boletos Boletos { get; set; } = new Boletos();
        public List<Pagamento> Pagamentos { get; set; } = new List<Pagamento>();
        public List<RegistroRetorno> Registros { get; set; } = new List<RegistroRetorno>();
        public DateTime? DataGeracao { get; set; }
        public int? NumeroSequencial { get; set; }

        private bool _ignorarCarteiraBoleto = false;


        #region Construtores

        public ArquivoRetorno(IBanco banco, TipoArquivo tipoArquivo, bool variasCarteiras = false)
        {
            Banco = banco;
            TipoArquivo = tipoArquivo;
            _ignorarCarteiraBoleto = variasCarteiras;
        }

        /// <summary>
        /// Neste construtor o BoletoNetCore é responsável por atribuir o TipoArquivo e o Banco de acordo com o conteúdo do arquivo de retorno.
        /// O próprio construtor chama o método LerArquivoRetorno2 responsável por carregar/atribuir os boletos e demais informações do arquivo de retorno
        /// </summary>
        /// <param name="arquivo">Stream do arquivo de retorno</param>
        public ArquivoRetorno(Stream arquivo)
        {
            LerArquivoRetorno2(arquivo);
        }

        #endregion

        public bool CheckTipoArquivoRetorno(Stream arquivo, string codBanco, string codAgencia, string numConta)
        {
            try
            {
                bool arquivoOk = true;
                using (StreamReader arquivoRetorno = new StreamReader(arquivo, System.Text.Encoding.UTF8))
                {
                    if (!arquivoRetorno.EndOfStream)
                    {
                        var header = arquivoRetorno.ReadLine();

                        if (TipoArquivo == TipoArquivo.REC390)
                        {
                            var rec390 = header.Substring(1, 6);
                            if (header.Length < 300)
                                arquivoOk = false;
                            else if (rec390.ToUpper().Trim() != "REC390")
                                arquivoOk = false;
                        }

                        if (TipoArquivo == TipoArquivo.CNAB400)
                        {
                            if (header.Length < 400)
                                arquivoOk = false;
                        }

                        if (TipoArquivo == TipoArquivo.CNAB240)
                        {
                            if (header.Length != 240)
                                arquivoOk = false;
                            else
                            {
                                var _codbanco = header.Substring(0, 3).TrimStart(new char[] { '0' });
                                var _codagencia = header.Substring(52, 5).TrimStart(new char[] { '0' });
                                var _numconta = header.Substring(58, 12).TrimStart(new char[] { '0' });


                                if (!codBanco.Trim().TrimStart(new char[] { '0' }).Equals(_codbanco.Trim()) ||
                                    !codAgencia.Trim().TrimStart(new char[] { '0' }).Equals(_codagencia.Trim()) ||
                                    !numConta.Trim().TrimStart(new char[] { '0' }).Equals(_numconta.Trim()))
                                    arquivoOk = false;
                            }

                        }
                    }
                }

                return arquivoOk;
            }
            catch (Exception ex)
            {
                throw new Exception("[CheckTipoArquivoRetorno] Erro ao checkar tipo do arquivo.", ex);
            }
        }

        public string GetIDCedenteRetorno(Stream arquivo)
        {
            try
            {
                string idCedente = string.Empty;

                if (TipoArquivo == TipoArquivo.CNAB400 && Banco.IdsRetornoCnab400RegistroDetalhe.Count == 0)
                    throw new Exception("Banco " + Banco.Codigo.ToString() + " não implementou os Ids do Registro Retorno do CNAB400.");

                using (StreamReader arquivoRetorno = new StreamReader(arquivo, System.Text.Encoding.UTF8))
                {
                    if (!arquivoRetorno.EndOfStream)
                    {
                        var header = arquivoRetorno.ReadLine();

                        if (TipoArquivo == TipoArquivo.CNAB240)
                        {
                            //todo
                            throw new NotImplementedException("[GetIDCedenteRetorno] CNAB240");
                        }
                        if (TipoArquivo == TipoArquivo.CNAB400)
                        {
                            idCedente = GetIDCedenteRetornoCNAB400(header);
                        }
                    }
                }

                return idCedente;
            }
            catch (Exception ex)
            {
                throw new Exception("[GetIDCedenteRetorno] Erro ao ler arquivo.", ex);
            }
        }

        public List<RegistroRetorno> LerArquivoRetorno(Stream arquivo)
        {
            Boletos.Clear();
            try
            {
                if (TipoArquivo == TipoArquivo.CNAB400 && Banco.IdsRetornoCnab400RegistroDetalhe.Count == 0)
                    throw new Exception("Banco " + Banco.Codigo.ToString() + " não implementou os Ids do Registro Retorno do CNAB400.");

                using (StreamReader arquivoRetorno = new StreamReader(arquivo, System.Text.Encoding.UTF8))
                {
                    while (!arquivoRetorno.EndOfStream)
                    {
                        var registro = arquivoRetorno.ReadLine();

                        if (TipoArquivo == TipoArquivo.CNAB240)
                        {
                            LerLinhaDoArquivoRetornoCNAB240(registro);
                        }

                        if (TipoArquivo == TipoArquivo.CNAB400)
                        {
                            LerLinhaDoArquivoRetornoCNAB400(registro);
                        }

                        if (TipoArquivo == TipoArquivo.REC390)
                        {
                            LerLinhaDoArquivoRetornoREC390(registro);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler arquivo.", ex);
            }
            return Registros;
        }

        private void LerArquivoRetorno2(Stream arquivo)
        {

            Boletos.Clear();
            try
            {
                using (StreamReader arquivoRetorno = new StreamReader(arquivo, System.Text.Encoding.UTF8))
                {
                    if (arquivoRetorno.EndOfStream)
                        return;

                    //busca o primeiro registro do arquivo
                    var registro = arquivoRetorno.ReadLine();

                    //atribui o tipo de acordo com o conteúdo do arquivo
                    TipoArquivo = registro.Length == 240 ? TipoArquivo.CNAB240 : TipoArquivo.CNAB400;

                    if (TipoArquivo == TipoArquivo.CNAB400 && Banco.IdsRetornoCnab400RegistroDetalhe.Count == 0)
                        throw new Exception("Banco " + Banco.Codigo.ToString() + " não implementou os Ids do Registro Retorno do CNAB400.");

                    //instacia o banco de acordo com o codigo/id do banco presente no arquivo de retorno
                    Banco = BoletoNetCore.Banco.Instancia(Utils.ToInt32(registro.Substring(TipoArquivo == TipoArquivo.CNAB240 ? 0 : 76, 3)));

                    //define a posicao do reader para o início
                    arquivoRetorno.DiscardBufferedData();
                    arquivoRetorno.BaseStream.Seek(0, SeekOrigin.Begin);

                    while (!arquivoRetorno.EndOfStream)
                    {
                        registro = arquivoRetorno.ReadLine();
                        if (TipoArquivo == TipoArquivo.CNAB240)
                        {
                            LerLinhaDoArquivoRetornoCNAB240(registro);
                        }
                        else
                        if (TipoArquivo == TipoArquivo.CNAB400)
                        {
                            LerLinhaDoArquivoRetornoCNAB400(registro);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao ler arquivo.", ex);
            }

        }

        private void LerLinhaDoArquivoRetornoCNAB240(string registro)
        {
            var tipoRegistro = registro.Substring(7, 1);
            var tipoSegmento = registro.Substring(13, 1);

            if (tipoRegistro == "0")
            {
                //REGISTRO HEADER DO ARQUIVO RETORNO
                Banco.LerHeaderRetornoCNAB240(this, registro);
                return;
            }

            if (tipoRegistro == "3" & tipoSegmento == "T")
            {
                // Segmento T - Indica um novo boleto
                var boleto = new Boleto(this.Banco, _ignorarCarteiraBoleto);

                Banco.LerDetalheRetornoCNAB240SegmentoT(ref boleto, registro);

                AddBoletoRetorno(tipoRegistro, tipoSegmento, boleto);

                return;
            }

            if (tipoRegistro == "3" & tipoSegmento == "U")
            {
                // Segmento U - Continuação do segmento T anterior (localiza o último boleto da lista)
                var boleto = Boletos.LastOrDefault();
                // Se não encontrou um boleto válido, ocorreu algum problema, pois deveria ter criado um novo objeto no registro que foi analisado anteriormente.
                if (boleto == null)
                    throw new Exception("Objeto boleto não identificado");

                Banco.LerDetalheRetornoCNAB240SegmentoU(ref boleto, registro);

                return;
            }

            //Segmento G = Retorno de Pagamentos via DDA
            if (tipoRegistro == "3" & tipoSegmento == "G")
            {
                var pagamento = new Pagamento();

                Banco.LerDetalheRetornoCNAB240SegmentoG(ref pagamento, registro);

                AddPagamentoRetorno(tipoRegistro, tipoSegmento, pagamento);

                return;
            }

            //Segmento H = DDA => Complemento do Registro G acima
            if (tipoRegistro == "3" & tipoSegmento == "H")
            {
                return;
            }

            //Segmento A = Retorno de Pagamentos via DOC/TED
            if (tipoRegistro == "3" & tipoSegmento == "A")
            {
                var pagamento = new Pagamento();

                Banco.LerDetalheRetornoCNAB240SegmentoA(ref pagamento, registro);

                AddPagamentoRetorno(tipoRegistro, tipoSegmento, pagamento);

                return;
            }

            //Segmento B = Retorno de Pagamentos via DOC/TED - Complemento do Segmento A
            if (tipoRegistro == "3" & tipoSegmento == "B")
            {
                var pagamento = Pagamentos.LastOrDefault();
                // Se não encontrou um boleto válido, ocorreu algum problema, pois deveria ter criado um novo objeto no registro que foi analisado anteriormente.
                if (pagamento == null)
                    throw new Exception("Objeto pagamento não identificado");

                Banco.LerDetalheRetornoCNAB240SegmentoB(ref pagamento, registro);

                return;
            }

            //Segmento J = Retorno de Pagamentos de titulos de cobranca
            if (tipoRegistro == "3" & tipoSegmento == "J")
            {
                //Marreta do segmento J-52
                var id52 = registro.Substring(17, 2);
                if (id52 != "52")
                {

                    var pagamento = new Pagamento();

                    Banco.LerDetalheRetornoCNAB240SegmentoJ(ref pagamento, registro);

                    AddPagamentoRetorno(tipoRegistro, tipoSegmento, pagamento);

                    return;
                }
            }

            //Segmento Z = Retorno de Pagamentos - Comprovantes/Autenticacao
            if (tipoRegistro == "3" & tipoSegmento == "Z")
            {
                var pagamento = Pagamentos.LastOrDefault();
                // Se não encontrou um boleto válido, ocorreu algum problema, pois deveria ter criado um novo objeto no registro que foi analisado anteriormente.
                if (pagamento == null)
                    throw new Exception("Objeto pagamento não identificado");

                Banco.LerDetalheRetornoCNAB240SegmentoZ(ref pagamento, registro);

                return;
            }

            //Segmento E = Retorno de Conciliacao bancaria
            if (tipoRegistro == "3" & tipoSegmento == "E")
            {
                var pagamento = new Pagamento();

                Banco.LerDetalheRetornoCNAB240SegmentoE(ref pagamento, registro);

                AddPagamentoRetorno(tipoRegistro, tipoSegmento, pagamento);

                return;
            }

            //Segmento O = Pagamento de Tributos
            if (tipoRegistro == "3" & tipoSegmento == "O")
            {
                var pagamento = new Pagamento();

                Banco.LerDetalheRetornoCNAB240SegmentoO(ref pagamento, registro);

                AddPagamentoRetorno(tipoRegistro, tipoSegmento, pagamento);

                return;
            }
        }

        private void LerLinhaDoArquivoRetornoREC390(string registro)
        {
            var tipoSegmento = registro.Substring(0, 1);

            if (tipoSegmento == "G")
            {
                var pagamento = new Pagamento();

                var bb = (Banco as BancoBrasil);

                bb.LerDetalheRetornoREC390SegmentoG(ref pagamento, registro);

                AddPagamentoRetorno("", tipoSegmento, pagamento);

                return;
            }
        }

        private void AddBoletoRetorno(string tipoRegistro, string tipoSegmento, Boleto boleto)
        {
            Boletos.Add(boleto);
            Registros.Add(new RegistroRetorno()
            {
                TipoRegistro = tipoRegistro,
                TipoSegmento = tipoSegmento,
                Boleto = boleto
            });
        }

        private void AddPagamentoRetorno(string tipoRegistro, string tipoSegmento, Pagamento pagamento)
        {
            Pagamentos.Add(pagamento);
            Registros.Add(new RegistroRetorno()
            {
                TipoRegistro = tipoRegistro,
                TipoSegmento = tipoSegmento,
                Pagamento = pagamento
            });
        }

        private string GetIDCedenteRetornoCNAB400(string registro)
        {
            // Identifica o tipo do registro (primeira posição da linha)
            var tipoRegistro = registro.Substring(0, 1);
            string codigoCedente = string.Empty;

            // Registro HEADER
            if (tipoRegistro == "0")
            {
                //Posicoes 27 a 46 do arquivo de retorno Cnab 400 todos os banco mandam um identificador unico da Conta/Cedente no Header
                codigoCedente = registro.Substring(26, 20);
            }
            return codigoCedente;
        }

        private void LerLinhaDoArquivoRetornoCNAB400(string registro)
        {
            // Identifica o tipo do registro (primeira posição da linha)
            var tipoRegistro = registro.Substring(0, 1);

            // Registro HEADER
            if (tipoRegistro == "0")
            {
                Banco.LerHeaderRetornoCNAB400(registro);
                return;
            }

            // Registro TRAILER
            if (tipoRegistro == "9")
            {
                Banco.LerTrailerRetornoCNAB400(registro);
                return;
            }

            // Se o registro não estiver na lista a ser processada pelo banco selecionado, ignora o registro
            if (!Banco.IdsRetornoCnab400RegistroDetalhe.Contains(tipoRegistro))
                return;

            // O primeiro ID da lista, identifica um novo boleto.
            bool novoBoleto = false;
            if (tipoRegistro == Banco.IdsRetornoCnab400RegistroDetalhe.First())
                novoBoleto = true;


            // Se for um novo boleto, cria um novo objeto, caso contrário, seleciona o último boleto
            // Estamos considerando que, quando houver mais de um registro para o mesmo boleto, no arquivo retorno, os registros serão apresentados na sequencia.
            Boleto boleto;
            if (novoBoleto)
            {
                boleto = new Boleto(this.Banco, _ignorarCarteiraBoleto);
            }
            else
            {
                boleto = Boletos.Last();
                // Se não encontrou um boleto válido, ocorreu algum problema, pois deveria ter criado um novo objeto no registro que foi analisado anteriormente.
                if (boleto == null)
                    throw new Exception("Objeto boleto não identificado");
            }


            // Identifica o tipo de registro que deve ser analisado pelo Banco.
            switch (tipoRegistro)
            {
                case "1":
                    Banco.LerDetalheRetornoCNAB400Segmento1(ref boleto, registro);
                    break;
                case "7":
                    Banco.LerDetalheRetornoCNAB400Segmento7(ref boleto, registro);
                    break;
                default:
                    break;
            }

            // Se for um novo boleto, adiciona na lista de boletos.
            if (novoBoleto)
            {
                Boletos.Add(boleto);
                Registros.Add(new RegistroRetorno()
                {
                    TipoRegistro = tipoRegistro,
                    TipoSegmento = tipoRegistro,
                    Boleto = boleto
                });
            }

        }
    }

}

