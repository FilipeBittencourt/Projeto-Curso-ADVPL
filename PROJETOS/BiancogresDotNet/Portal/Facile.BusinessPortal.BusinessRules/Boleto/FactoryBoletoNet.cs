using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Linq;
using Facile.Financeiro.BoletoNetCore;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Library.Mail;

namespace Facile.BusinessPortal.BusinessRules.Boleto
{
    public static class FactoryBoletoNet
    {
    
        public static Facile.Financeiro.BoletoNetCore.Boleto CreateBoletoNet(Model.Boleto boletoBase, bool validData = true)
        {
            IBanco _banco;

            
            var contaBancaria = new Facile.Financeiro.BoletoNetCore.ContaBancaria
            {
                Agencia = boletoBase.Cedente.ContaBancaria.Agencia,
                DigitoAgencia = boletoBase.Cedente.ContaBancaria.DigitoAgencia,
                Conta = boletoBase.Cedente.ContaBancaria.Conta,
                DigitoConta = boletoBase.Cedente.ContaBancaria.DigitoConta,
                CarteiraPadrao = boletoBase.Cedente.ContaBancaria.CarteiraPadrao ?? string.Empty,
                VariacaoCarteiraPadrao = boletoBase.Cedente.ContaBancaria.VariacaoCarteiraPadrao ?? string.Empty,
            };
            if (boletoBase.Cedente.ContaBancaria.TipoCarteiraPadrao.HasValue)
            {
                contaBancaria.TipoCarteiraPadrao = (Facile.Financeiro.BoletoNetCore.TipoCarteira)boletoBase.Cedente.ContaBancaria.TipoCarteiraPadrao.Value;
            }
            if (boletoBase.Cedente.ContaBancaria.TipoFormaCadastramento.HasValue)
            {
                contaBancaria.TipoFormaCadastramento = (Facile.Financeiro.BoletoNetCore.TipoFormaCadastramento)boletoBase.Cedente.ContaBancaria.TipoFormaCadastramento.Value;
            }
            if (boletoBase.Cedente.ContaBancaria.TipoImpressaoBoleto.HasValue)
            {
                contaBancaria.TipoImpressaoBoleto = (Facile.Financeiro.BoletoNetCore.TipoImpressaoBoleto)boletoBase.Cedente.ContaBancaria.TipoImpressaoBoleto.Value;
            }

            Bancos oBanco;
            if (boletoBase.CodigoBanco == "001")
                oBanco = Bancos.BancoDoBrasil;
            else if (boletoBase.CodigoBanco == "237")
                oBanco = Bancos.Bradesco;
            else if (boletoBase.CodigoBanco == "021")
                oBanco = Bancos.Banestes;
            else
            {
                return null;
            }

            _banco = Facile.Financeiro.BoletoNetCore.Banco.Instancia(oBanco);


            _banco.Cedente = new Facile.Financeiro.BoletoNetCore.Cedente
            {
                CPFCNPJ = boletoBase.Cedente.CPFCNPJ,
                Nome = boletoBase.Cedente.Nome,
                Codigo = boletoBase.Cedente.CodigoCedenteBanco,
               // CodigoDV = boletoBase.Cedente.CodigoDV,
                Endereco = new Facile.Financeiro.BoletoNetCore.Endereco
                {
                    LogradouroEndereco = boletoBase.Cedente.Logradouro?? "",
                    LogradouroNumero = boletoBase.Cedente.Numero??"",
                    LogradouroComplemento = boletoBase.Cedente.Complemento?? "",
                    Bairro = boletoBase.Cedente.Bairro,
                    Cidade = boletoBase.Cedente.Cidade,
                    UF = boletoBase.Cedente.UF,
                    CEP = boletoBase.Cedente.CEP
                },
                ContaBancaria = contaBancaria
            };

            _banco.FormataCedente();

            var boleto = new Facile.Financeiro.BoletoNetCore.Boleto(_banco)
            {
                Sacado = new Facile.Financeiro.BoletoNetCore.Sacado
                {
                    CPFCNPJ = boletoBase.Sacado.CPFCNPJ,
                    Nome = boletoBase.Sacado.Nome,
                    Observacoes = boletoBase.Sacado.Observacoes
                },
                DataEmissao = boletoBase.DataEmissao,
                DataProcessamento = DateTime.Today.Date,
                DataVencimento = boletoBase.DataVencimento,
                ValorTitulo = boletoBase.ValorTitulo,
                NossoNumero = boletoBase.NossoNumero,
                NumeroDocumento = boletoBase.NumeroDocumento,
                EspecieDocumento = TipoEspecieDocumento.DM,
                Aceite = string.IsNullOrEmpty(boletoBase.Aceite) ?"N": boletoBase.Aceite,
                CodigoInstrucao1 = boletoBase.CodigoInstrucao1,
                CodigoInstrucao2 = boletoBase.CodigoInstrucao2
            };

            if (boletoBase.Sacado != null)
            {
                boleto.Sacado.Endereco = new Endereco
                {
                    LogradouroEndereco = boletoBase.Sacado.Logradouro ?? "",
                    LogradouroNumero = boletoBase.Sacado.Numero ?? "",
                    Bairro = boletoBase.Sacado.Bairro,
                    Cidade = boletoBase.Sacado.Cidade,
                    UF = boletoBase.Sacado.UF,
                    CEP = boletoBase.Sacado.CEP
                };
            }

            if (boletoBase.DataDesconto.HasValue)
                boleto.DataDesconto = boletoBase.DataDesconto.Value;

            if (boletoBase.ValorDesconto.HasValue)
                boleto.ValorDesconto = boletoBase.ValorDesconto.Value;

            if (boletoBase.ValorDesconto.HasValue)
                boleto.ValorDesconto = boletoBase.ValorDesconto.Value;

            if (boletoBase.DataMulta.HasValue)
                boleto.DataMulta = boletoBase.DataMulta.Value;

            if (boletoBase.PercentualMulta.HasValue)
                boleto.PercentualMulta = boletoBase.PercentualMulta.Value;

            if (boletoBase.ValorMulta.HasValue)
                boleto.ValorMulta = boletoBase.ValorMulta.Value;

            if (boletoBase.ValorOutrosAcrescimos.HasValue)
                boleto.ValorOutrosAcrescimos = boletoBase.ValorOutrosAcrescimos.Value;

            if (boletoBase.DataJuros.HasValue)
                boleto.DataJuros = boletoBase.DataJuros.Value;

            if (boletoBase.PercentualJurosDia.HasValue)
                boleto.PercentualJurosDia = boletoBase.PercentualJurosDia.Value;

            if (boletoBase.ValorJurosDia.HasValue)
                boleto.ValorJurosDia = boletoBase.ValorJurosDia.Value;

            if (!string.IsNullOrWhiteSpace(boletoBase.MensagemArquivoRemessa))
                boleto.MensagemArquivoRemessa = boletoBase.MensagemArquivoRemessa;
            else
                boleto.MensagemArquivoRemessa = string.Empty;

            if (!string.IsNullOrWhiteSpace(boletoBase.MensagemInstrucoesCaixa))
                boleto.MensagemInstrucoesCaixa = boletoBase.MensagemInstrucoesCaixa;
            else
                boleto.MensagemInstrucoesCaixa = string.Empty;

            boleto.NumeroControleParticipante = boletoBase.NumeroControleParticipante;

            if (boletoBase.Cedente.ContaBancaria.FIDCAtivo == 1)
            {
                if (boletoBase.Cedente.ContaBancaria.FIDC != null)
                {
                    boleto.Avalista = new Facile.Financeiro.BoletoNetCore.Sacado
                    {
                        CPFCNPJ = boletoBase.Cedente.CPFCNPJ,
                        Nome = boletoBase.Cedente.Nome,
                        Observacoes = "",
                        Endereco = new Endereco
                        {
                            LogradouroEndereco = boletoBase.Cedente.Logradouro ?? "",
                            LogradouroNumero = boletoBase.Cedente.Numero ?? "",
                            Bairro = boletoBase.Cedente.Bairro,
                            Cidade = boletoBase.Cedente.Cidade,
                            UF = boletoBase.Cedente.UF,
                            CEP = boletoBase.Cedente.CEP
                        }
                    };

                    boleto.Banco.Cedente.CPFCNPJ = boletoBase.Cedente.ContaBancaria.FIDC.CPFCNPJ;
                    boleto.Banco.Cedente.Nome = boletoBase.Cedente.ContaBancaria.FIDC.Nome;
                    boleto.Banco.Cedente.Endereco.LogradouroEndereco = boletoBase.Cedente.ContaBancaria.FIDC.Logradouro ?? "";
                    boleto.Banco.Cedente.Endereco.LogradouroNumero = boletoBase.Cedente.ContaBancaria.FIDC.Numero ?? "";
                    boleto.Banco.Cedente.Endereco.LogradouroComplemento = boletoBase.Cedente.ContaBancaria.FIDC.Complemento ?? "";
                    boleto.Banco.Cedente.Endereco.Bairro = boletoBase.Cedente.ContaBancaria.FIDC.Bairro ?? "";
                    boleto.Banco.Cedente.Endereco.Cidade = boletoBase.Cedente.ContaBancaria.FIDC.Cidade ?? "";
                    boleto.Banco.Cedente.Endereco.UF = boletoBase.Cedente.ContaBancaria.FIDC.UF ?? "";
                    boleto.Banco.Cedente.Endereco.CEP = boletoBase.Cedente.ContaBancaria.FIDC.CEP ?? "";
                    
                    /* boleto.Banco.Cedente = new Facile.Financeiro.BoletoNetCore.Cedente
                     {
                         CPFCNPJ = boletoBase.Cedente.ContaBancaria.FIDC.CPFCNPJ,
                         Nome = boletoBase.Cedente.ContaBancaria.FIDC.Nome,
                         Codigo = "",
                         // CodigoDV = boletoBase.Cedente.CodigoDV,
                         Endereco = new Facile.Financeiro.BoletoNetCore.Endereco
                         {
                             LogradouroEndereco = boletoBase.Cedente.ContaBancaria.FIDC.Logradouro ?? "",
                             LogradouroNumero = boletoBase.Cedente.ContaBancaria.FIDC.Numero ?? "",
                             LogradouroComplemento = boletoBase.Cedente.ContaBancaria.FIDC.Complemento ?? "",
                             Bairro = boletoBase.Cedente.ContaBancaria.FIDC.Bairro,
                             Cidade = boletoBase.Cedente.ContaBancaria.FIDC.Cidade,
                             UF = boletoBase.Cedente.ContaBancaria.FIDC.UF,
                             CEP = boletoBase.Cedente.ContaBancaria.FIDC.CEP
                         },
                         ContaBancaria = contaBancaria
                     };*/
                }

            }


            //VALIDAR DADOS DO BOLETO.NET
            boleto.ValidarDados();

            return boleto;
        }


        public static List<Financeiro.BoletoNetCore.Boleto> ListBoletoToBoletoNet(List<Model.Boleto> boletoBase)
        {
            List<Financeiro.BoletoNetCore.Boleto> listBoleto = new List<Financeiro.BoletoNetCore.Boleto>();

            foreach (var b in boletoBase)
            {
                var boletoNet = FactoryBoletoNet.CreateBoletoNet(b);
                listBoleto.Add(boletoNet);
            }
            return listBoleto;
        }
    }
}
